module ImagesHelper
  def image_absolute_url(image, version)
    return "" unless image

    polymorphic_url(image.variant(version))
  end

  def render_image(image, version, show_caption = true)
    render Images::ImageComponent.new(image, (version if image.persisted?), show_caption: show_caption)
  end

  def attached_background_css(path)
    "background-image: url('#{j path}');"
  end
end
