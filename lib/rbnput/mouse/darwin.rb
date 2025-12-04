# frozen_string_literal: true

require 'ffi'
require_relative 'base'
require_relative '../darwin_util'

module Rbnput
  module Mouse
    # macOS implementation using Quartz/CoreGraphics
    module Darwin
      extend FFI::Library
      ffi_lib '/System/Library/Frameworks/ApplicationServices.framework/ApplicationServices'

      # CGEvent types
      KCGEventMouseMoved = 5
      KCGEventLeftMouseDown = 1
      KCGEventLeftMouseUp = 2
      KCGEventRightMouseDown = 3
      KCGEventRightMouseUp = 4
      KCGEventOtherMouseDown = 25
      KCGEventOtherMouseUp = 26
      KCGEventScrollWheel = 22

      # Mouse buttons
      KCGMouseButtonLeft = 0
      KCGMouseButtonRight = 1
      KCGMouseButtonCenter = 2

      # FFI bindings
      attach_function :CGEventCreate, [:pointer], :pointer
      attach_function :CGEventCreateMouseEvent, [:pointer, :int, :pointer, :int], :pointer
      attach_function :CGEventCreateScrollWheelEvent, [:pointer, :int, :int, :int, :int], :pointer
      attach_function :CGEventPost, [:int, :pointer], :void
      attach_function :CGEventGetLocation, [:pointer], :pointer
      attach_function :CFRelease, [:pointer], :void
      attach_function :CGEventSourceCreate, [:int], :pointer

      # Button mapping
      module Button
        UNKNOWN = Rbnput::Mouse::Button::UNKNOWN
        LEFT = Rbnput::Mouse::Button::LEFT
        MIDDLE = Rbnput::Mouse::Button::MIDDLE
        RIGHT = Rbnput::Mouse::Button::RIGHT
        X1 = Rbnput::Mouse::Button::X1
        X2 = Rbnput::Mouse::Button::X2
      end

      # macOS Mouse Controller
      class Controller < Rbnput::Mouse::Controller
        def initialize
          super
          @event_source = Darwin.CGEventSourceCreate(1)
        end

        protected

        def _position_get
          # Create a temporary event to get current mouse location
          event = Darwin.CGEventCreate(nil)
          location_ptr = Darwin.CGEventGetLocation(event)
          location = location_ptr.read_array_of_double(2)
          Darwin.CFRelease(event)
          [location[0].to_i, location[1].to_i]
        end

        def _position_set(x, y)
          # Create a mouse move event
          location = FFI::MemoryPointer.new(:double, 2)
          location.write_array_of_double([x.to_f, y.to_f])
          
          event = Darwin.CGEventCreateMouseEvent(@event_source, KCGEventMouseMoved, location, 0)
          Darwin.CGEventPost(0, event)
          Darwin.CFRelease(event)
        end

        def _scroll(dx, dy)
          event = Darwin.CGEventCreateScrollWheelEvent(@event_source, 0, 2, dy, dx)
          Darwin.CGEventPost(0, event)
          Darwin.CFRelease(event)
        end

        def _press(button)
          _click(button, true)
        end

        def _release(button)
          _click(button, false)
        end

        private

        def _click(button, is_press)
          x, y = position
          location = FFI::MemoryPointer.new(:double, 2)
          location.write_array_of_double([x.to_f, y.to_f])

          event_type, button_num = case button
                                    when Button::LEFT
                                      [is_press ? KCGEventLeftMouseDown : KCGEventLeftMouseUp, KCGMouseButtonLeft]
                                    when Button::RIGHT
                                      [is_press ? KCGEventRightMouseDown : KCGEventRightMouseUp, KCGMouseButtonRight]
                                    when Button::MIDDLE
                                      [is_press ? KCGEventOtherMouseDown : KCGEventOtherMouseUp, KCGMouseButtonCenter]
                                    else
                                      raise ArgumentError, "Unknown button: #{button}"
                                    end

          event = Darwin.CGEventCreateMouseEvent(@event_source, event_type, location, button_num)
          Darwin.CGEventPost(0, event)
          Darwin.CFRelease(event)
        end
      end

      # macOS Mouse Listener
      class Listener < Rbnput::Mouse::Listener
        include DarwinUtil::ListenerMixin

        # Event types
        KCGEventLeftMouseDown = 1
        KCGEventLeftMouseUp = 2
        KCGEventRightMouseDown = 3
        KCGEventRightMouseUp = 4
        KCGEventMouseMoved = 5
        KCGEventLeftMouseDragged = 6
        KCGEventRightMouseDragged = 7
        KCGEventScrollWheel = 22
        KCGEventOtherMouseDown = 25
        KCGEventOtherMouseUp = 26
        KCGEventOtherMouseDragged = 27

        EVENTS_MASK = (1 << KCGEventMouseMoved) |
                      (1 << KCGEventLeftMouseDown) |
                      (1 << KCGEventLeftMouseUp) |
                      (1 << KCGEventLeftMouseDragged) |
                      (1 << KCGEventRightMouseDown) |
                      (1 << KCGEventRightMouseUp) |
                      (1 << KCGEventRightMouseDragged) |
                      (1 << KCGEventOtherMouseDown) |
                      (1 << KCGEventOtherMouseUp) |
                      (1 << KCGEventOtherMouseDragged) |
                      (1 << KCGEventScrollWheel)

        protected

        def _handle_message(proxy, type, event, refcon, injected)
          location = DarwinUtil.CGEventGetLocation(event)
          x, y = location[:x].to_i, location[:y].to_i

          case type
          when KCGEventMouseMoved, KCGEventLeftMouseDragged, KCGEventRightMouseDragged, KCGEventOtherMouseDragged
            on_move&.call(x, y, injected)
          when KCGEventScrollWheel
            dy = DarwinUtil.CGEventGetIntegerValueField(event, DarwinUtil::kCGScrollWheelEventDeltaAxis1)
            dx = DarwinUtil.CGEventGetIntegerValueField(event, DarwinUtil::kCGScrollWheelEventDeltaAxis2)
            on_scroll&.call(x, y, dx, dy, injected)
          else
            # Button events
            button = case type
                     when KCGEventLeftMouseDown, KCGEventLeftMouseUp
                       Button::LEFT
                     when KCGEventRightMouseDown, KCGEventRightMouseUp
                       Button::RIGHT
                     when KCGEventOtherMouseDown, KCGEventOtherMouseUp
                       Button::MIDDLE # Simplified, could be others
                     else
                       Button::UNKNOWN
                     end
            
            pressed = [KCGEventLeftMouseDown, KCGEventRightMouseDown, KCGEventOtherMouseDown].include?(type)
            on_click&.call(x, y, button, pressed, injected)
          end
        end
      end
    end
  end
end
