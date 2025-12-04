# frozen_string_literal: true

require_relative 'mouse/base'

module Rbnput
  # The module containing mouse classes
  module Mouse
    # Determine backend and load appropriate implementation
    backend = case RUBY_PLATFORM
              when /darwin/
                require_relative 'mouse/darwin'
                Darwin
              when /linux/
                require_relative 'mouse/xorg'
                Xorg
              when /mingw|mswin/
                require_relative 'mouse/win32'
                Win32
              else
                require_relative 'mouse/dummy'
                Dummy
              end

    # Export backend classes
    Button = backend::Button
    Controller = backend::Controller
    Listener = backend::Listener

    # Mouse event listener supporting synchronous iteration over events
    class Events < Util::Events
      _Listener = Listener

      # A mouse move event
      class Move < Event
        attr_reader :x, :y, :injected

        def initialize(x, y, injected = false)
          super()
          @x = x
          @y = y
          @injected = injected
        end

        def to_s
          "Move(x=#{@x}, y=#{@y}, injected=#{@injected})"
        end
      end

      # A mouse click event
      class Click < Event
        attr_reader :x, :y, :button, :pressed, :injected

        def initialize(x, y, button, pressed, injected = false)
          super()
          @x = x
          @y = y
          @button = button
          @pressed = pressed
          @injected = injected
        end

        def to_s
          action = @pressed ? 'Press' : 'Release'
          "Click(#{action}, button=#{@button}, x=#{@x}, y=#{@y}, injected=#{@injected})"
        end
      end

      # A mouse scroll event
      class Scroll < Event
        attr_reader :x, :y, :dx, :dy, :injected

        def initialize(x, y, dx, dy, injected = false)
          super()
          @x = x
          @y = y
          @dx = dx
          @dy = dy
          @injected = injected
        end

        def to_s
          "Scroll(x=#{@x}, y=#{@y}, dx=#{@dx}, dy=#{@dy}, injected=#{@injected})"
        end
      end

      def initialize
        super(
          on_move: Move,
          on_click: Click,
          on_scroll: Scroll
        )
      end
    end
  end
end
