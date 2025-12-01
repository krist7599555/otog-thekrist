# frozen_string_literal: true

require 'ffi'
require_relative 'base'

module Rbnpuy
  module Keyboard
    # macOS implementation using Quartz/CoreGraphics
    module Darwin
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

      # KeyCode implementation for macOS
      class KeyCode < Rbnpuy::Keyboard::KeyCode
        attr_reader :_is_media

        def initialize(vk: nil, char: nil, is_dead: false, _is_media: false, **kwargs)
          super(vk: vk, char: char, is_dead: is_dead, **kwargs)
          @_is_media = _is_media
        end

        def self._from_media(vk, **kwargs)
          new(vk: vk, _is_media: true, **kwargs)
        end
      end

      # macOS-specific key codes
      module Key
        # Modifier keys
        ALT = KeyCode.from_vk(0x3A)
        ALT_L = KeyCode.from_vk(0x3A)
        ALT_R = KeyCode.from_vk(0x3D)
        ALT_GR = KeyCode.from_vk(0x3D)
        
        BACKSPACE = KeyCode.from_vk(0x33)
        CAPS_LOCK = KeyCode.from_vk(0x39)
        
        CMD = KeyCode.from_vk(0x37)
        CMD_L = KeyCode.from_vk(0x37)
        CMD_R = KeyCode.from_vk(0x36)
        
        CTRL = KeyCode.from_vk(0x3B)
        CTRL_L = KeyCode.from_vk(0x3B)
        CTRL_R = KeyCode.from_vk(0x3E)
        
        DELETE = KeyCode.from_vk(0x75)
        DOWN = KeyCode.from_vk(0x7D)
        KEY_END = KeyCode.from_vk(0x77)
        ENTER = KeyCode.from_vk(0x24)
        ESC = KeyCode.from_vk(0x35)
        
        F1 = KeyCode.from_vk(0x7A)
        F2 = KeyCode.from_vk(0x78)
        F3 = KeyCode.from_vk(0x63)
        F4 = KeyCode.from_vk(0x76)
        F5 = KeyCode.from_vk(0x60)
        F6 = KeyCode.from_vk(0x61)
        F7 = KeyCode.from_vk(0x62)
        F8 = KeyCode.from_vk(0x64)
        F9 = KeyCode.from_vk(0x65)
        F10 = KeyCode.from_vk(0x6D)
        F11 = KeyCode.from_vk(0x67)
        F12 = KeyCode.from_vk(0x6F)
        F13 = KeyCode.from_vk(0x69)
        F14 = KeyCode.from_vk(0x6B)
        F15 = KeyCode.from_vk(0x71)
        F16 = KeyCode.from_vk(0x6A)
        F17 = KeyCode.from_vk(0x40)
        F18 = KeyCode.from_vk(0x4F)
        F19 = KeyCode.from_vk(0x50)
        F20 = KeyCode.from_vk(0x5A)
        
        HOME = KeyCode.from_vk(0x73)
        LEFT = KeyCode.from_vk(0x7B)
        PAGE_DOWN = KeyCode.from_vk(0x79)
        PAGE_UP = KeyCode.from_vk(0x74)
        RIGHT = KeyCode.from_vk(0x7C)
        
        SHIFT = KeyCode.from_vk(0x38)
        SHIFT_L = KeyCode.from_vk(0x38)
        SHIFT_R = KeyCode.from_vk(0x3C)
        
        SPACE = KeyCode.from_vk(0x31)
        TAB = KeyCode.from_vk(0x30)
        UP = KeyCode.from_vk(0x7E)

        # Media keys
        MEDIA_PLAY_PAUSE = KeyCode._from_media(16)
        MEDIA_VOLUME_MUTE = KeyCode._from_media(7)
        MEDIA_VOLUME_DOWN = KeyCode._from_media(1)
        MEDIA_VOLUME_UP = KeyCode._from_media(0)
        MEDIA_PREVIOUS = KeyCode._from_media(20)
        MEDIA_NEXT = KeyCode._from_media(17)
      end

      # macOS Keyboard Controller
      class Controller < Rbnpuy::Keyboard::Controller
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
                       when Key::SHIFT, Key::SHIFT_L, Key::SHIFT_R
                         KCGEventFlagMaskShift
                       when Key::CTRL, Key::CTRL_L, Key::CTRL_R
                         KCGEventFlagMaskControl
                       when Key::ALT, Key::ALT_L, Key::ALT_R
                         KCGEventFlagMaskAlternate
                       when Key::CMD, Key::CMD_L, Key::CMD_R
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
      class Listener < Rbnpuy::Keyboard::Listener
        protected

        def _run
          # Note: Full implementation would require CFRunLoop and event tap setup
          # This is a simplified version
          @log.warn("macOS keyboard listener requires additional implementation")
          @log.warn("Consider using accessibility permissions and CGEventTap")
          
          # Keep thread alive
          sleep 0.1 while @running
        end
      end
    end
  end
end
