module ImagesHelper
  def image_absolute_url(image, version)
    return "" unless image

    if Paperclip::Attachment.default_options[:storage] == :filesystem
      URI(request.url) + image.attachment.url(version)
    else
      image.attachment.url(version)
    end
  end

  def image_class(image)
    image.persisted? ? "persisted-image" : "cached-image"
  end

  def render_image(image, version, show_caption = true)
    version = image.persisted? ? version : :original
    render "images/image", image: image, version: version, show_caption: show_caption
  end
end
