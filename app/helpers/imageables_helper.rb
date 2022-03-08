module ImageablesHelper
  def can_destroy_image?(imageable)
    imageable.image.present? && can?(:destroy, imageable.image)
  end

  def imageable_max_file_size
    Setting["uploads.images.max_size"].to_i
  end

  def imageable_accepted_content_types
    Setting["uploads.images.content_types"]&.split(" ") || ["image/jpeg"]
  end

  def imageable_accepted_content_types_extensions
    Setting.accepted_content_types_for("images").map do |content_type|
      if content_type == "jpg"
        ".jpg,.jpeg"
      else
        ".#{content_type}"
      end
    end.join(",")
  end

  def imageable_humanized_accepted_content_types
    Setting.accepted_content_types_for("images").join(", ")
  end

  def imageables_note(_imageable)
    t "images.form.note", accepted_content_types: imageable_humanized_accepted_content_types,
                          max_file_size: imageable_max_file_size
  end
end
