module ImagesHelper
  def image_absolute_url(image, version)
    return "" unless image

    polymorphic_url(image.variant(version))
  end

  def image_class(image)
    image.persisted? ? "persisted-image" : "cached-image"
  end

  def render_image(image, version, show_caption = true)
    render "images/image", image: image,
                           version: (version if image.persisted?),
                           show_caption: show_caption
  end
end
