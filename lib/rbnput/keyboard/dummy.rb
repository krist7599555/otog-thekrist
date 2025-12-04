# frozen_string_literal: true

module Rbnpuy
  module Keyboard
    # Dummy implementation for unsupported platforms
    module Dummy
      class KeyCode < Base::KeyCode
      end

      module Key
        # Import all keys from base
        Base::Key.constants.each do |const|
          const_set(const, Base::Key.const_get(const))
        end
      end

      class Controller < Base::Controller
        def initialize
          super
          @log.warn("Keyboard control is not implemented for this platform")
        end

        protected

        def _handle(key, is_press)
          action = is_press ? "Press" : "Release"
          @log.debug("Dummy: #{action} #{key}")
        end
      end

      class Listener < Base::Listener
        protected

        def _run
          @log.warn("Keyboard listening is not implemented for this platform")
          sleep 0.1 while @running
        end
      end
    end
  end
end
