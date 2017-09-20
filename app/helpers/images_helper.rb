module ImagesHelper

  def image_absolute_url(image, version)
    return "" unless image
    if Paperclip::Attachment.default_options[:storage] == :filesystem
      URI(request.url) + image.attachment.url(version)
    else
      investment.image_url(version)
    end
  end

  def image_note(image)
    t "images.new.#{image.imageable.class.name.parameterize.underscore}.note",
      title: image.imageable.title
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

  def image_bytesToMeg(bytes)
    bytes / Numeric::MEGABYTE
  end

  def image_nested_field_name(image, field)
    parent = image.imageable_type.parameterize.underscore
    "#{parent.parameterize}[image_attributes]#{field}"
  end

  def image_nested_field_id(image, field)
    parent = image.imageable_type.parameterize.underscore
    "#{parent.parameterize}_image_attributes_#{field}"
  end

  def image_nested_field_wrapper_id
    "nested_image"
  end

  def image_class(image)
    image.persisted? ? "image" : "cached-image"
  end

  def render_destroy_image_link(image)
    if image.persisted?
      link_to t('images.form.delete_button'),
              image_path(image, nested_image: true),
              method: :delete,
              remote: true,
              data: { confirm: t('images.actions.destroy.confirm') },
              class: "delete remove-image"
    elsif !image.persisted? && image.cached_attachment.present?
      link_to t('images.form.delete_button'),
              destroy_upload_images_path(path: image.cached_attachment,
                                            nested_image: true,
                                            imageable_type: image.imageable_type,
                                            imageable_id: image.imageable_id),
              method: :delete,
              remote: true,
              class: "delete remove-cached-attachment"
    else
      link_to t('images.form.delete_button'),
              "#",
              class: "delete remove-nested-field"
    end
  end

  def render_image_attachment(image)
    html = file_field_tag :attachment,
                          accept: imageable_accepted_content_types_extensions,
                          class: 'direct_upload_image_attachment',
                          data: {
                            url: image_direct_upload_url(image),
                            cached_attachment_input_field: image_nested_field_id(image, :cached_attachment),
                            title_input_field: image_nested_field_id(image, :title),
                            multiple: false,
                            nested_image: true
                          },
                          name: image_nested_field_name(image, :attachment),
                          id: image_nested_field_id(image, :attachment)
    if image.attachment.blank? && image.cached_attachment.blank?
      klass = image.errors[:attachment].any? ? "error" : ""
      html += label_tag image_nested_field_id(image, :attachment),
                       t("images.form.attachment_label"),
                       class: "button hollow #{klass}"
      if image.errors[:attachment].any?
        html += content_tag :small, class: "error" do
          image_errors_on_attachment(image)
        end
      end
    end
    html
  end

  def render_image(image, version, show_caption = true)
    version = image.persisted? ? version : :original
    render partial: "images/image", locals: { image: image,
                                              version: version,
                                              show_caption: show_caption }
  end

  def image_direct_upload_url(image)
    direct_uploads_url("direct_upload[resource_type]": image.imageable_type,
                       "direct_upload[resource_id]": image.imageable_id,
                       "direct_upload[resource_relation]": "image")
  end

end
