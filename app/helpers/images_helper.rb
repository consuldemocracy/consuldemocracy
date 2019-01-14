module ImagesHelper

  def image_absolute_url(image, version)
    return "" unless image
    if Paperclip::Attachment.default_options[:storage] == :filesystem
      URI(request.url) + image.attachment.url(version)
    else
      investment.image_url(version)
    end
  end

  def image_first_recommendation(image)
    t "images.#{image.imageable.class.name.parameterize.underscore}.recommendation_one_html",
      title: image.imageable.title
  end

  def image_attachment_file_name(image)
    image.attachment_file_name
  end

  def image_errors_on_attachment(image)
    image.errors[:attachment].join(', ') if image.errors.key?(:attachment)
  end

  def image_bytes_to_megabytes(bytes)
    bytes / Numeric::MEGABYTE
  end

  def image_class(image)
    image.persisted? ? "persisted-image" : "cached-image"
  end

  def render_destroy_image_link(builder, image)
    if !image.persisted? && image.cached_attachment.present?
      link_to t('images.form.delete_button'),
              direct_upload_destroy_url("direct_upload[resource_type]": image.imageable_type,
                                        "direct_upload[resource_id]": image.imageable_id,
                                        "direct_upload[resource_relation]": "image",
                                        "direct_upload[cached_attachment]": image.cached_attachment),
              method: :delete,
              remote: true,
              class: "delete remove-cached-attachment"
    else
      link_to_remove_association t('images.form.delete_button'), builder, class: "delete remove-image"
    end
  end

  def render_image_attachment(builder, imageable, image)
    klass = image.errors[:attachment].any? ? "error" : ""
    klass = image.persisted? || image.cached_attachment.present? ? " hide" : ""
    html = builder.label :attachment,
                          t("images.form.attachment_label"),
                          class: "button hollow #{klass}"
    html += builder.file_field :attachment,
                               label: false,
                               accept: imageable_accepted_content_types_extensions,
                               class: 'js-image-attachment',
                               data: {
                                 url: image_direct_upload_url(imageable),
                                 nested_image: true
                               }

    html
  end

  def render_image(image, version, show_caption = true)
    version = image.persisted? ? version : :original
    render partial: "images/image", locals: { image: image,
                                              version: version,
                                              show_caption: show_caption }
  end

  def image_direct_upload_url(imageable)
    direct_uploads_url("direct_upload[resource_type]": imageable.class.name,
                       "direct_upload[resource_id]": imageable.id,
                       "direct_upload[resource_relation]": "image")
  end

end
