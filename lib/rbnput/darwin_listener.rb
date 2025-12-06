# frozen_string_literal: true

require 'set'
require_relative './key_code'
require_relative './simple_mutex_thread'
require_relative './darwin_ffi'

module Rbnput
  # Base listener for keyboard events
  class DarwinListener < Rbnput::SimpleMutexThread
    def initialize(on_press: nil, on_release: nil, **kwargs)
      super(*kwargs)
      @on_press = on_press
      @on_release = on_release

      @loop = nil
      @tap = nil
      @callback_proc = nil # Keep reference to prevent GC
    end
    attr_reader :on_press, :on_release

    def _run
      unless Rbnput::DarwinFFI.AXIsProcessTrusted()
        @log.warn("Process is not trusted! Input monitoring will not work until added to accessibility clients.")
      end

      # Create the callback
      @callback_proc = FFI::Function.new(:pointer, [:pointer, :int, :pointer, :pointer]) do |proxy, type, event, refcon|
        key_code = DarwinFFI
          .CGEventGetIntegerValueField(event, Rbnput::DarwinFFI::KCGKeyboardEventKeycode)
          .then { |vk| KeyCode.from_vk(vk) }
        
        case type
        when Rbnput::DarwinFFI::KCGEventKeyDown;      @on_press&.call(key_code)
        when Rbnput::DarwinFFI::KCGEventKeyUp;        @on_release&.call(key_code)
        when Rbnput::DarwinFFI::KCGEventFlagsChanged; @on_press&.call(key_code)
        end
        event
      end

      @tap = Rbnput::DarwinFFI.CGEventTapCreate(
        Rbnput::DarwinFFI::KCGSessionEventTap,
        Rbnput::DarwinFFI::KCGHeadInsertEventTap,
        Rbnput::DarwinFFI::KCGEventTapOptionDefault,
        (1 << Rbnput::DarwinFFI::KCGEventKeyDown)  | (1 << Rbnput::DarwinFFI::KCGEventKeyUp) | (1 << Rbnput::DarwinFFI::KCGEventFlagsChanged),
        @callback_proc,
        nil
      )

      if @tap.null?
        @log.error("Failed to create event tap")
        return
      end

      # Create run loop source
      source = Rbnput::DarwinFFI.CFMachPortCreateRunLoopSource(nil, @tap, 0)
      
      # Add to current run loop
      @loop = Rbnput::DarwinFFI.CFRunLoopGetCurrent()
      Rbnput::DarwinFFI.CFRunLoopAddSource(@loop, source, Rbnput::DarwinFFI.kCFRunLoopDefaultMode)
      
      # Enable tap
      Rbnput::DarwinFFI.CGEventTapEnable(@tap, true)
      
      # Run loop
      while @running
        _result = Rbnput::DarwinFFI.CFRunLoopRunInMode(Rbnput::DarwinFFI.kCFRunLoopDefaultMode, 0.1, false)
        
        # 0.1 second timeout allows us to check @running flag
      end
    ensure
      Rbnput::DarwinFFI.CFRelease(@tap) if @tap && !@tap.null?
      Rbnput::DarwinFFI.CFRelease(source) if source && !source.null?
      @tap = nil
      @loop = nil
    end

    def stop
      super
      Rbnput::DarwinFFI.CFRunLoopStop(@loop) if @loop && !@loop.null?
    end

  end
end
