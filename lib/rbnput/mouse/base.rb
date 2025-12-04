# frozen_string_literal: true

module Rbnpuy
  module Mouse
    # Mouse button enumeration
    module Button
      UNKNOWN = :unknown
      LEFT = :left
      MIDDLE = :middle
      RIGHT = :right
      X1 = :x1
      X2 = :x2

      def self.all
        [UNKNOWN, LEFT, MIDDLE, RIGHT, X1, X2]
      end
    end

    # Base controller for sending virtual mouse events
    class Controller
      attr_reader :log

      def initialize
        @log = Rbnpuy.logger(self.class)
      end

      # Get or set the current mouse position
      # @return [Array<Integer, Integer>] current position as [x, y]
      def position
        _position_get
      end

      def position=(pos)
        x, y = pos
        _position_set(x, y)
      end

      # Send scroll events
      # @param dx [Integer] horizontal scroll amount
      # @param dy [Integer] vertical scroll amount
      def scroll(dx, dy)
        _scroll(dx, dy)
      end

      # Press a mouse button
      # @param button [Symbol] the button to press
      def press(button)
        _press(button)
      end

      # Release a mouse button
      # @param button [Symbol] the button to release
      def release(button)
        _release(button)
      end

      # Move the mouse relative to current position
      # @param dx [Integer] horizontal offset
      # @param dy [Integer] vertical offset
      def move(dx, dy)
        x, y = position
        self.position = [x + dx, y + dy]
      end

      # Click a mouse button
      # @param button [Symbol] the button to click
      # @param count [Integer] number of clicks
      def click(button, count = 1)
        count.times do
          press(button)
          release(button)
        end
      end

      protected

      # Platform-specific implementations
      # These must be implemented by platform-specific subclasses

      def _position_get
        raise NotImplementedError
      end

      def _position_set(x, y)
        raise NotImplementedError
      end

      def _scroll(dx, dy)
        raise NotImplementedError
      end

      def _press(button)
        raise NotImplementedError
      end

      def _release(button)
        raise NotImplementedError
      end
    end

    # Base listener for mouse events
    class Listener < Util::AbstractListener
      def initialize(on_move: nil, on_click: nil, on_scroll: nil, suppress: false, **kwargs)
        # Extract platform-specific options
        option_prefix = '_'
        platform_options = kwargs.select { |key, _| key.to_s.start_with?(option_prefix) }
        
        super(suppress: suppress, **platform_options)
        
        @on_move = _wrap(on_move, 3)
        @on_click = _wrap(on_click, 5)
        @on_scroll = _wrap(on_scroll, 5)
      end

      protected

      attr_reader :on_move, :on_click, :on_scroll
    end
  end
end
