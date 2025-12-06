# frozen_string_literal: true

require 'set'

module Rbnput
  # Represents a key code used by the operating system
  class KeyCode
    attr_reader :vk, :char, :is_media, :is_dead

    def initialize(vk: nil, char: nil, is_dead: false, is_media: false, **kwargs)
      @vk = vk
      @char = char
      @is_dead = is_dead
      @is_media = is_media
      @platform_extensions = kwargs
    end

    def to_s
      [
        @vk.nil? ? "" : "vk=#{@vk}",
        @char.nil? ? "" : "char=#{@char}",
        @is_media ? "media" : "",
        @is_dead ? "dead" : "",
      ]
      .reject(&:empty?)
      .join(", ")
      .then { "KeyCode(#{_1})" }
      
    end

    def ==(other)
      return false unless other.is_a?(KeyCode)
      @vk == other.vk && @char == other.char && @is_dead == other.is_dead && @is_media == other.is_media
    end

    def hash
      [@vk, @char, @is_media, @is_dead].hash
    end

    alias eql? ==

    # Create a key code from a virtual key code
    def self.from_vk(vk, **kwargs)
      new(vk: vk, **kwargs)
    end
    def self.from_media(vk, **kwargs)
      new(vk: vk, is_media: true, **kwargs)
    end

    # Create a key code from a character
    def self.from_char(char, **kwargs)
      new(char: char, **kwargs)
    end

  end

  # Special keys that may not correspond to letters
  module BaseKey
    # Modifier keys
    ALT = KeyCode.from_vk(0x12)
    ALT_L = KeyCode.from_vk(0x12)
    ALT_R = KeyCode.from_vk(0x13)
    ALT_GR = KeyCode.from_vk(0x13)
    
    CTRL = KeyCode.from_vk(0x11)
    CTRL_L = KeyCode.from_vk(0x11)
    CTRL_R = KeyCode.from_vk(0x11)
    
    SHIFT = KeyCode.from_vk(0x10)
    SHIFT_L = KeyCode.from_vk(0x10)
    SHIFT_R = KeyCode.from_vk(0x10)
    
    CMD = KeyCode.from_vk(0x5B)
    CMD_L = KeyCode.from_vk(0x5B)
    CMD_R = KeyCode.from_vk(0x5C)

    # Special keys
    BACKSPACE = KeyCode.from_vk(0x08)
    CAPS_LOCK = KeyCode.from_vk(0x14)
    DELETE = KeyCode.from_vk(0x2E)
    DOWN = KeyCode.from_vk(0x28)
    KEY_END = KeyCode.from_vk(0x23)
    ENTER = KeyCode.from_vk(0x0D)
    ESC = KeyCode.from_vk(0x1B)
    HOME = KeyCode.from_vk(0x24)
    INSERT = KeyCode.from_vk(0x2D)
    LEFT = KeyCode.from_vk(0x25)
    MENU = KeyCode.from_vk(0x5D)
    NUM_LOCK = KeyCode.from_vk(0x90)
    PAGE_DOWN = KeyCode.from_vk(0x22)
    PAGE_UP = KeyCode.from_vk(0x21)
    PAUSE = KeyCode.from_vk(0x13)
    PRINT_SCREEN = KeyCode.from_vk(0x2C)
    RIGHT = KeyCode.from_vk(0x27)
    SCROLL_LOCK = KeyCode.from_vk(0x91)
    SPACE = KeyCode.from_vk(0x20)
    TAB = KeyCode.from_vk(0x09)
    UP = KeyCode.from_vk(0x26)

    # Function keys
    F1 = KeyCode.from_vk(0x70)
    F2 = KeyCode.from_vk(0x71)
    F3 = KeyCode.from_vk(0x72)
    F4 = KeyCode.from_vk(0x73)
    F5 = KeyCode.from_vk(0x74)
    F6 = KeyCode.from_vk(0x75)
    F7 = KeyCode.from_vk(0x76)
    F8 = KeyCode.from_vk(0x77)
    F9 = KeyCode.from_vk(0x78)
    F10 = KeyCode.from_vk(0x79)
    F11 = KeyCode.from_vk(0x7A)
    F12 = KeyCode.from_vk(0x7B)
    F13 = KeyCode.from_vk(0x7C)
    F14 = KeyCode.from_vk(0x7D)
    F15 = KeyCode.from_vk(0x7E)
    F16 = KeyCode.from_vk(0x7F)
    F17 = KeyCode.from_vk(0x80)
    F18 = KeyCode.from_vk(0x81)
    F19 = KeyCode.from_vk(0x82)
    F20 = KeyCode.from_vk(0x83)

    # Media keys
    MEDIA_PLAY_PAUSE = KeyCode.from_vk(0xB3)
    MEDIA_VOLUME_MUTE = KeyCode.from_vk(0xAD)
    MEDIA_VOLUME_DOWN = KeyCode.from_vk(0xAE)
    MEDIA_VOLUME_UP = KeyCode.from_vk(0xAF)
    MEDIA_PREVIOUS = KeyCode.from_vk(0xB1)
    MEDIA_NEXT = KeyCode.from_vk(0xB0)
  end
  
  # Base controller for sending virtual keyboard events
  class BaseController
    attr_reader :log

    def initialize
      @log = Rbnput.logger(self.class)
      @modifiers = Set.new
      @modifiers_lock = Mutex.new
    end

    # Press a key
    # @param key [String, KeyCode, Key] the key to press
    def press(key)
      resolved = _resolve(key)
      _handle(resolved, true)
      _update_modifiers(resolved, true)
    end

    # Release a key
    # @param key [String, KeyCode, Key] the key to release
    def release(key)
      resolved = _resolve(key)
      _handle(resolved, false)
      _update_modifiers(resolved, false)
    end

    # Press and release a key
    # @param key [String, KeyCode, Key] the key to tap
    def tap(key)
      press(key)
      release(key)
    end

    # Type a string
    # @param string [String] the string to type
    def type(string)
      string.each_char do |char|
        # Check if it's a control code
        key = CONTROL_CODES[char] || char
        tap(key)
      end
    end

    # Execute a block with modifiers pressed
    def pressed(*keys)
      keys.each { |key| press(key) }
      yield if block_given?
    ensure
      keys.reverse.each { |key| release(key) }
    end

    protected

    # Resolve a key to a KeyCode
    def _resolve(key)
      case key
      when String
        raise ArgumentError, "String keys must be of length 1" if key.length != 1
        KeyCode.from_char(key)
      when KeyCode
        key
      else
        # Assume it's a Key constant
        key
      end
    end

    # Update the set of currently pressed modifiers
    def _update_modifiers(key, is_press)
      @modifiers_lock.synchronize do
        if is_press
          @modifiers.add(key) if NORMAL_MODIFIERS.key?(key)
        else
          @modifiers.delete(key)
        end
      end
    end

    # Platform-specific key handling
    def _handle(key, is_press)
      raise NotImplementedError
    end
  end

  # Base listener for keyboard events
  class BaseListener < Util::AbstractListener
    require_relative "../darwin_util"
    include Rbnput::DarwinUtil::ListenerMixin
    def initialize(on_press: nil, on_release: nil, suppress: false, **kwargs)
      # Extract platform-specific options
      option_prefix = '_'
      platform_options = kwargs.select { |key, _| key.to_s.start_with?(option_prefix) }
      
      super(suppress: suppress, **platform_options)
      
      @on_press = _wrap(on_press, 2)
      @on_release = _wrap(on_release, 2)
    end

    # Normalize a key to its canonical form
    def canonical(key)
      NORMAL_MODIFIERS[key] || key
    end

    protected

    attr_reader :on_press, :on_release
  end
end
