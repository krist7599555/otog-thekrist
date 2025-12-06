# frozen_string_literal: true

require 'ffi'

module Rbnput::DarwinFFI
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
  attach_function :CGEventGetType, [:pointer], :int
  attach_function :CGEventGetFlags, [:pointer], :uint64
  attach_function :CGEventCreateKeyboardEvent, [:pointer, :uint16, :bool], :pointer
  attach_function :CGEventPost, [:int, :pointer], :void
  attach_function :CGEventSourceCreate, [:int], :pointer
  attach_function :CFRelease, [:pointer], :void
  attach_function :CGEventSetFlags, [:pointer, :uint64], :void
  
  # Constants for fields
  KCGEventSourceUnixProcessID = 1
  KCGKeyboardEventKeycode = 9
  KCGScrollWheelEventDeltaAxis1 = 11 # Y
  KCGScrollWheelEventDeltaAxis2 = 12 # X
  
  KCGEventKeyDown = 10
  KCGEventKeyUp = 11
  KCGEventFlagsChanged = 12
  
  KCG_EVENT_FLAG_KEYDOWN_KEYUP_FLAGSCHANGED = (1 << KCGEventKeyDown) | (1 << KCGEventKeyUp) | (1 << KCGEventFlagsChanged)

end