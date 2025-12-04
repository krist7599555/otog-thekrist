# frozen_string_literal: true

require 'ffi'

module Rbnput
  module DarwinUtil
    extend FFI::Library
    ffi_lib ['/System/Library/Frameworks/ApplicationServices.framework/ApplicationServices',
             '/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation']

    # CoreFoundation types
    typedef :pointer, :CFMachPortRef
    typedef :pointer, :CFRunLoopSourceRef
    typedef :pointer, :CFRunLoopRef
    typedef :pointer, :CFStringRef
    typedef :pointer, :CGEventTapProxy
    typedef :pointer, :CGEventRef
    
    # Constants
    KCGSessionEventTap = 0
    KCGHeadInsertEventTap = 0
    KCGEventTapOptionDefault = 0x00000000
    KCGEventTapOptionListenOnly = 0x00000001
    
    KCFRunLoopRunFinished = 1
    KCFRunLoopRunStopped = 2
    KCFRunLoopRunTimedOut = 3
    KCFRunLoopRunHandledSource = 4
    
    # We need to get the kCFRunLoopDefaultMode constant value
    # It's a CFStringRef. For simplicity in FFI, we can often pass NULL (0) for default mode in some APIs,
    # but CFRunLoopAddSource requires a mode.
    # A common workaround is to look it up or define it if we know the symbol name.
    # However, getting the actual pointer value of a constant exported by a dylib in FFI can be tricky.
    # We'll try to attach it.
    attach_variable :kCFRunLoopDefaultMode, :kCFRunLoopDefaultMode, :pointer

    # CGEventTapCallback
    callback :CGEventTapCallback, [:pointer, :int, :pointer, :pointer], :pointer

    # Functions
    attach_function :CGEventTapCreate, [:int, :int, :int, :uint64, :CGEventTapCallback, :pointer], :CFMachPortRef
    attach_function :CGEventTapEnable, [:CFMachPortRef, :bool], :void
    attach_function :CFMachPortCreateRunLoopSource, [:pointer, :CFMachPortRef, :long], :CFRunLoopSourceRef
    attach_function :CFRunLoopGetCurrent, [], :CFRunLoopRef
    attach_function :CFRunLoopAddSource, [:CFRunLoopRef, :CFRunLoopSourceRef, :pointer], :void
    attach_function :CFRunLoopRunInMode, [:pointer, :double, :bool], :int
    attach_function :CFRunLoopStop, [:CFRunLoopRef], :void
    attach_function :CFRelease, [:pointer], :void
    
    attach_function :AXIsProcessTrusted, [], :bool
    
    attach_function :CGEventGetIntegerValueField, [:pointer, :int], :int64
    attach_function :CGEventGetLocation, [:pointer], :pointer # Returns CGPoint struct by value? No, usually CGPoint is struct.
    # FFI handling of struct return values can be tricky. CGEventGetLocation returns CGPoint (struct).
    # We need to define CGPoint.
    
    class CGPoint < FFI::Struct
      layout :x, :double,
             :y, :double
    end
    
    attach_function :CGEventGetLocation, [:pointer], CGPoint.by_value
    attach_function :CGEventGetType, [:pointer], :int
    attach_function :CGEventGetFlags, [:pointer], :uint64
    
    # Constants for fields
    KCGEventSourceUnixProcessID = 1
    KCGKeyboardEventKeycode = 9
    KCGScrollWheelEventDeltaAxis1 = 11 # Y
    KCGScrollWheelEventDeltaAxis2 = 12 # X

    module ListenerMixin
      def self.included(base)
        base.include(InstanceMethods)
      end

      module InstanceMethods
        def initialize(**kwargs)
          super
          @loop = nil
          @tap = nil
          @callback_proc = nil # Keep reference to prevent GC
        end

        def _run
          unless DarwinUtil.AXIsProcessTrusted()
            @log.warn("Process is not trusted! Input monitoring will not work until added to accessibility clients.")
          end

          # Create the callback
          @callback_proc = FFI::Function.new(:pointer, [:pointer, :int, :pointer, :pointer]) do |proxy, type, event, refcon|
            _handler(proxy, type, event, refcon)
          end

          mask = self.class::EVENTS_MASK

          # Create event tap
          options = @suppress ? DarwinUtil::KCGEventTapOptionDefault : DarwinUtil::KCGEventTapOptionListenOnly
          
          @tap = DarwinUtil.CGEventTapCreate(
            DarwinUtil::KCGSessionEventTap,
            DarwinUtil::KCGHeadInsertEventTap,
            options,
            mask,
            @callback_proc,
            nil
          )

          if @tap.null?
            @log.error("Failed to create event tap")
            return
          end

          # Create run loop source
          source = DarwinUtil.CFMachPortCreateRunLoopSource(nil, @tap, 0)
          
          # Add to current run loop
          @loop = DarwinUtil.CFRunLoopGetCurrent()
          DarwinUtil.CFRunLoopAddSource(@loop, source, DarwinUtil.kCFRunLoopDefaultMode)
          
          # Enable tap
          DarwinUtil.CGEventTapEnable(@tap, true)
          
          # Run loop
          while @running
            _result = DarwinUtil.CFRunLoopRunInMode(DarwinUtil.kCFRunLoopDefaultMode, 0.1, false)
            # 0.1 second timeout allows us to check @running flag
          end
        ensure
          if @tap && !@tap.null?
            DarwinUtil.CFRelease(@tap)
            @tap = nil
          end
          if source && !source.null?
            DarwinUtil.CFRelease(source)
          end
          @loop = nil
        end

        def stop
          super
          if @loop && !@loop.null?
            DarwinUtil.CFRunLoopStop(@loop)
          end
        end

        def _handler(proxy, type, event, refcon)
          # Check if injected
          pid = DarwinUtil.CGEventGetIntegerValueField(event, DarwinUtil::KCGEventSourceUnixProcessID)
          is_injected = pid != 0

          _result = _handle_message(proxy, type, event, refcon, is_injected)
          
          if @suppress
            # If suppressing, we return NULL to eat the event, or the event itself to pass it
            return nil # Suppress
          end
          
          event
        end
      end
    end
  end
end
