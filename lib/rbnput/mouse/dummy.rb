# frozen_string_literal: true

module Rbnput
  module Mouse
    # Dummy implementation for unsupported platforms
    module Dummy
      module Button
        UNKNOWN = Base::Button::UNKNOWN
        LEFT = Base::Button::LEFT
        MIDDLE = Base::Button::MIDDLE
        RIGHT = Base::Button::RIGHT
        X1 = Base::Button::X1
        X2 = Base::Button::X2
      end

      class Controller < Base::Controller
        def initialize
          super
          @log.warn("Mouse control is not implemented for this platform")
          @position = [0, 0]
        end

        protected

        def _position_get
          @position
        end

        def _position_set(x, y)
          @position = [x, y]
          @log.debug("Dummy: Set position to (#{x}, #{y})")
        end

        def _scroll(dx, dy)
          @log.debug("Dummy: Scroll (#{dx}, #{dy})")
        end

        def _press(button)
          @log.debug("Dummy: Press #{button}")
        end

        def _release(button)
          @log.debug("Dummy: Release #{button}")
        end
      end

      class Listener < Base::Listener
        protected

        def _run
          @log.warn("Mouse listening is not implemented for this platform")
          sleep 0.1 while @running
        end
      end
    end
  end
end
