class Attachable::FieldsComponent < ApplicationComponent
  attr_reader :f, :resource_type, :resource_id, :relation_name
  delegate :current_user, :render_image, to: :helpers

  def initialize(f, resource_type:, resource_id:, relation_name:)
    @f = f
    @resource_type = resource_type
    @resource_id = resource_id
    @relation_name = relation_name
  end

  private

    def attachable
      f.object
    end

    def singular_name
      attachable.model_name.singular
    end

    def plural_name
      attachable.model_name.plural
    end

    def file_name
      attachable.attachment_file_name
    end

    def destroy_link
      if !attachable.persisted? && attachable.cached_attachment.present?
        link_to t("#{plural_name}.form.delete_button"), "#", class: "delete remove-cached-attachment"
      else
        link_to_remove_association remove_association_text, f, class: "delete remove-#{singular_name}"
      end
    end

    def remove_association_text
      if attachable.new_record?
        t("documents.form.cancel_button")
      else
        t("#{plural_name}.form.delete_button")
      end
    end

    def file_field
      klass = attachable.persisted? || attachable.cached_attachment.present? ? " hide" : ""
      f.file_field :attachment,
                   label_options: { class: "button hollow #{klass}" },
                   accept: accepted_content_types_extensions,
                   class: "js-#{singular_name}-attachment",
                   data: { url: direct_upload_path }
    end

    def direct_upload_path
      direct_uploads_path("direct_upload[resource_type]": resource_type,
                          "direct_upload[resource_id]": resource_id,
                          "direct_upload[resource_relation]": relation_name)
    end

    def accepted_content_types_extensions
      Setting.accepted_content_types_for(plural_name).map do |content_type|
        if content_type == "jpg"
          ".jpg,.jpeg"
        else
          ".#{content_type}"
        end
      end.join(",")
    end
end
