require_relative "./key_code_const"

class Rbnput::KeyCode
  attr_reader :vk, :is_media

  def initialize(vk: nil, is_media: false)
    @vk = vk
    @is_media = is_media
  end

  def to_s
    [
      @vk.nil? ? "" : "vk=#{@vk}",
      @is_media ? "media" : "",
    ]
    .reject(&:empty?)
    .join(", ")
    .then { "KeyCode(#{_1}, #{key})" }
  end

  def key
    KEY_CODE_HEX_TO_NAME[@vk] || "UNKNOW"
  end

  def ==(other)
    return false unless other.is_a?(KeyCode)
    @vk == other.vk && @is_media == other.is_media
  end

  alias eql? ==

  def hash
    [@vk, @is_media].hash
  end

  def self.from_vk(vk, **kwargs)
    new(vk: vk, is_media: false, **kwargs)
  end

  def self.from_media(vk, **kwargs)
    new(vk: vk, is_media: true, **kwargs)
  end

end

