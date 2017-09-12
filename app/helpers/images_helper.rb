module ImagesHelper

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
              class: "delete float-right"
    elsif !image.persisted? && image.cached_attachment.present?
      link_to t('images.form.delete_button'),
              destroy_upload_images_path(path: image.cached_attachment,
                                            nested_image: true,
                                            imageable_type: image.imageable_type,
                                            imageable_id: image.imageable_id),
              method: :delete,
              remote: true,
              class: "delete float-right"
    else
      link_to t('images.form.delete_button'),
              "#",
              class: "delete float-right remove-image"
    end
  end

  def render_image_attachment(image)
    html = file_field_tag :attachment,
                          accept: imageable_accepted_content_types_extensions,
                          class: 'image_ajax_attachment',
                          data: {
                            url: image_direct_upload_url(image),
                            cached_attachment_input_field: image_nested_field_id(image, :cached_attachment),
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
    upload_images_url(
       imageable_type: image.imageable_type,
       imageable_id: image.imageable_id,
       format: :js
     )
  end

end
