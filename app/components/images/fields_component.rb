class Images::FieldsComponent < ApplicationComponent
  attr_reader :f, :imageable
  delegate :current_user, :render_image, to: :helpers

  def initialize(f, imageable:)
    @f = f
    @imageable = imageable
  end

  private

    def image
      f.object
    end

    def file_name
      image.attachment_file_name
    end

    def destroy_link
      if !image.persisted? && image.cached_attachment.present?
        link_to t("images.form.delete_button"),
          direct_upload_destroy_path(
            "direct_upload[resource_type]": image.imageable_type,
            "direct_upload[resource_id]": image.imageable_id,
            "direct_upload[resource_relation]": "image",
            "direct_upload[cached_attachment]": image.cached_attachment
          ),
          method: :delete,
          remote: true,
          class: "delete remove-cached-attachment"
      else
        link_to_remove_association t("images.form.delete_button"), f, class: "delete remove-image"
      end
    end

    def file_field
      klass = image.persisted? || image.cached_attachment.present? ? " hide" : ""
      f.file_field :attachment,
        label_options: { class: "button hollow #{klass}" },
        accept: accepted_content_types_extensions,
        class: "js-image-attachment",
        data: {
          url: direct_upload_path,
          nested_image: true
        }
    end

    def direct_upload_path
      direct_uploads_path("direct_upload[resource_type]": imageable.class.name,
                          "direct_upload[resource_id]": imageable.id,
                          "direct_upload[resource_relation]": "image")
    end

    def accepted_content_types_extensions
      Setting.accepted_content_types_for("images").map do |content_type|
        if content_type == "jpg"
          ".jpg,.jpeg"
        else
          ".#{content_type}"
        end
      end.join(",")
    end
end
