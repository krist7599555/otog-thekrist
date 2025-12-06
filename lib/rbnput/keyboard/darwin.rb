# frozen_string_literal: true

require 'ffi'
require_relative 'base'
require_relative '../darwin_util'


# macOS implementation using Quartz/CoreGraphics
module Rbnput
  extend FFI::Library
  ffi_lib '/System/Library/Frameworks/ApplicationServices.framework/ApplicationServices'

  # CGEvent types
  KCGEventKeyDown = 10
  KCGEventKeyUp = 11
  KCGEventFlagsChanged = 12

  # Modifier flags
  KCGEventFlagMaskShift = 0x00020000
  KCGEventFlagMaskControl = 0x00040000
  KCGEventFlagMaskAlternate = 0x00080000
  KCGEventFlagMaskCommand = 0x00100000

  # FFI bindings
  attach_function :CGEventCreateKeyboardEvent, [:pointer, :uint16, :bool], :pointer
  attach_function :CGEventPost, [:int, :pointer], :void
  attach_function :CGEventSourceCreate, [:int], :pointer
  attach_function :CFRelease, [:pointer], :void
  attach_function :CGEventSetFlags, [:pointer, :uint64], :void


  # macOS Keyboard Controller
  class DarwinController < Rbnput::BaseController
    def initialize
      super
      @event_source = Darwin.CGEventSourceCreate(1)
    end

    protected

    def _handle(key, is_press)
      resolved_key = key.is_a?(Base::KeyCode) ? key : _resolve(key)
      # Get the virtual key code
      vk = if resolved_key.respond_to?(:vk)
              resolved_key.vk
            elsif resolved_key.respond_to?(:char)
              # Map character to virtual key code (simplified)
              _char_to_vk(resolved_key.char)
            else
              raise ArgumentError, "Cannot determine virtual key code for #{resolved_key}"
            end

      # Create and post keyboard event
      event = Darwin.CGEventCreateKeyboardEvent(@event_source, vk, is_press)
      
      # Set modifier flags if needed
      flags = _get_modifier_flags
      Darwin.CGEventSetFlags(event, flags) if flags > 0
      
      Darwin.CGEventPost(0, event)
      Darwin.CFRelease(event)
    end

    private

    # Simple character to virtual key code mapping
    def _char_to_vk(char)
      case char.downcase
      when 'a' then 0x00
      when 'b' then 0x0B
      when 'c' then 0x08
      when 'd' then 0x02
      when 'e' then 0x0E
      when 'f' then 0x03
      when 'g' then 0x05
      when 'h' then 0x04
      when 'i' then 0x22
      when 'j' then 0x26
      when 'k' then 0x28
      when 'l' then 0x25
      when 'm' then 0x2E
      when 'n' then 0x2D
      when 'o' then 0x1F
      when 'p' then 0x23
      when 'q' then 0x0C
      when 'r' then 0x0F
      when 's' then 0x01
      when 't' then 0x11
      when 'u' then 0x20
      when 'v' then 0x09
      when 'w' then 0x0D
      when 'x' then 0x07
      when 'y' then 0x10
      when 'z' then 0x06
      when '0' then 0x1D
      when '1' then 0x12
      when '2' then 0x13
      when '3' then 0x14
      when '4' then 0x15
      when '5' then 0x17
      when '6' then 0x16
      when '7' then 0x1A
      when '8' then 0x1C
      when '9' then 0x19
      else 0x31 # Default to space
      end
    end

    def _get_modifier_flags
      flags = 0
      @modifiers_lock.synchronize do
        @modifiers.each do |mod|
          flags |= case mod
                    when DarwinKey::SHIFT, DarwinKey::SHIFT_L, DarwinKey::SHIFT_R
                      KCGEventFlagMaskShift
                    when DarwinKey::CTRL, DarwinKey::CTRL_L, DarwinKey::CTRL_R
                      KCGEventFlagMaskControl
                    when DarwinKey::ALT, DarwinKey::ALT_L, DarwinKey::ALT_R
                      KCGEventFlagMaskAlternate
                    when DarwinKey::CMD, DarwinKey::CMD_L, DarwinKey::CMD_R
                      KCGEventFlagMaskCommand
                    else
                      0
                    end
        end
      end
      flags
    end
  end

  # macOS Keyboard Listener
  class DarwinListener < ::Rbnput::BaseListener
    puts("UseDarwinListener")
    include ::Rbnput::DarwinUtil::ListenerMixin

    # Event types
    KCGEventKeyDown = 10
    KCGEventKeyUp = 11
    KCGEventFlagsChanged = 12

    EVENTS_MASK = (1 << KCGEventKeyDown) |
                  (1 << KCGEventKeyUp) |
                  (1 << KCGEventFlagsChanged)

    protected

    def _handle_message(proxy, type, event, refcon, injected)
      vk = DarwinUtil.CGEventGetIntegerValueField(event, DarwinUtil::KCGKeyboardEventKeycode)
      
      # Convert VK to KeyCode
      # Ideally we should use TIS/Carbon to map to characters, but for now we use VK
      # We can try to map back using our Key constants if possible, or just return VK
      puts "_handle_message(#{vk})"
      key = KeyCode.from_vk(vk)
      
      case type
      when KCGEventKeyDown
        on_press&.call(key, injected)
      when KCGEventKeyUp
        on_release&.call(key, injected)
      when KCGEventFlagsChanged
        # Flags changed is tricky because it doesn't tell us if it's press or release
        # We need to track state or check flags
        # For simplicity in this clone, we might treat it as press if flag is set?
        # But we don't know WHICH key caused it easily without tracking previous state.
        # pynput tracks state.
        
        # Simplified: just notify press for now if we can identify the key
        # Real implementation needs to check if the specific flag bit changed
        on_press&.call(key, injected)
      end
    end
  end
end
