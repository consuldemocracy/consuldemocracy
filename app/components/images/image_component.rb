class Images::ImageComponent < ApplicationComponent
  attr_reader :image, :version, :show_caption

  def initialize(image, version, show_caption: true)
    @image = image
    @version = version
    @show_caption = show_caption
  end

  private

    def image_class
      image.persisted? ? "persisted-image" : "cached-image"
    end
end
