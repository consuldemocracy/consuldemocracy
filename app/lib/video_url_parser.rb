class VideoUrlParser
  attr_reader :url

  VIMEO_REGEX = /vimeo.*(staffpicks\/|channels\/|videos\/|video\/|\/)([^#\&\?]*).*/
  YOUTUBE_REGEX = /youtu.*(be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*/

  def initialize(url)
    @url = url
  end

  def valid?
    match.present?
  end

  def embed_url
    if VIMEO_REGEX.match?(url)
      "https://player.vimeo.com/video/#{url_id}?dnt=1"
    elsif YOUTUBE_REGEX.match?(url)
      "https://www.youtube-nocookie.com/embed/#{url_id}"
    end
  end

  private

    def match
      VIMEO_REGEX.match(url) || YOUTUBE_REGEX.match(url)
    end

    def url_id
      match[2] if match
    end
end
