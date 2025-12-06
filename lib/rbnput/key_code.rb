class Rbnput::KeyCode
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