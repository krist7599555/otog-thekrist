# frozen_string_literal: true

require_relative 'keyboard/base'

module Rbnput
  # The module containing keyboard classes
  module Keyboard
    # Determine backend and load appropriate implementation
    backend = case RUBY_PLATFORM
              when /darwin/
                require_relative 'keyboard/darwin'
                Darwin
              when /linux/
                require_relative 'keyboard/xorg'
                Xorg
              when /mingw|mswin/
                require_relative 'keyboard/win32'
                Win32
              else
                require_relative 'keyboard/dummy'
                Dummy
              end

    # Export backend classes
    KeyCode = backend::KeyCode
    Key = backend::Key
    Controller = backend::Controller
    Listener = backend::Listener

    # Modifier keys mapping
    MODIFIER_KEYS = [
      [Key::ALT_GR, [Key::ALT_GR]],
      [Key::ALT, [Key::ALT, Key::ALT_L, Key::ALT_R]],
      [Key::CMD, [Key::CMD, Key::CMD_L, Key::CMD_R]],
      [Key::CTRL, [Key::CTRL, Key::CTRL_L, Key::CTRL_R]],
      [Key::SHIFT, [Key::SHIFT, Key::SHIFT_L, Key::SHIFT_R]]
    ].freeze

    # Normalized modifiers mapping
    NORMAL_MODIFIERS = MODIFIER_KEYS.flat_map do |base, variants|
      variants.map { |v| [v, base] }
    end.to_h.freeze

    # Control codes to transform into key codes when typing
    CONTROL_CODES = {
      "\n" => Key::ENTER,
      "\r" => Key::ENTER,
      "\t" => Key::TAB
    }.freeze

    # Keyboard event listener supporting synchronous iteration
    class Events < Util::Events
      _Listener = Listener

      # A key press event
      class Press < Event
        attr_reader :key, :injected

        def initialize(key, injected = false)
          super()
          @key = key
          @injected = injected
        end

        def to_s
          "Press(key=#{@key}, injected=#{@injected})"
        end
      end

      # A key release event
      class Release < Event
        attr_reader :key, :injected

        def initialize(key, injected = false)
          super()
          @key = key
          @injected = injected
        end

        def to_s
          "Release(key=#{@key}, injected=#{@injected})"
        end
      end

      def initialize
        super(
          on_press: Press,
          on_release: Release
        )
      end
    end

    # A combination of keys acting as a hotkey
    class HotKey
      def initialize(keys, on_activate)
        @state = Set.new
        @keys = Set.new(keys)
        @on_activate = on_activate
      end

      # Parse a key combination string
      # @param keys [String] key combination like '<ctrl>+<alt>+h'
      # @return [Array<KeyCode>] parsed keys
      def self.parse(keys)
        parts = keys.split('+').map(&:strip)
        
        parts.map do |part|
          if part.length == 1
            KeyCode.from_char(part.downcase)
          elsif part.start_with?('<') && part.end_with?('>')
            key_name = part[1...-1].upcase
            begin
              key = Key.const_get(key_name)
              # Return modifiers as Key instances, others as KeyCodes
              if NORMAL_MODIFIERS.values.include?(key)
                key
              else
                KeyCode.from_vk(key.vk) if key.respond_to?(:vk)
              end
            rescue NameError
              # Try to parse as virtual key code
              KeyCode.from_vk(part[1...-1].to_i) if part[1...-1].match?(/^\d+$/)
            end
          else
            raise ArgumentError, "Invalid key part: #{part}"
          end
        end.compact
      end

      # Update hotkey state for a pressed key
      def press(key)
        if @keys.include?(key) && !@state.include?(key)
          @state.add(key)
          @on_activate.call if @state == @keys
        end
      end

      # Update hotkey state for a released key
      def release(key)
        @state.delete(key) if @state.include?(key)
      end
    end

    # A keyboard listener supporting global hotkeys
    class GlobalHotKeys < Listener
      def initialize(hotkeys, **kwargs)
        @hotkeys = hotkeys.map do |key_combo, callback|
          HotKey.new(HotKey.parse(key_combo), callback)
        end

        super(
          on_press: method(:_on_press),
          on_release: method(:_on_release),
          **kwargs
        )
      end

      private

      def _on_press(key, injected)
        return if injected
        
        canonical_key = canonical(key)
        @hotkeys.each { |hotkey| hotkey.press(canonical_key) }
      end

      def _on_release(key, injected)
        return if injected
        
        canonical_key = canonical(key)
        @hotkeys.each { |hotkey| hotkey.release(canonical_key) }
      end

      def canonical(key)
        # Normalize modifier keys
        NORMAL_MODIFIERS[key] || key
      end
    end
  end
end
