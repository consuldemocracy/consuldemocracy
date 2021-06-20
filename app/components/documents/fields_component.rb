class Documents::FieldsComponent < ApplicationComponent
  attr_reader :f
  delegate :current_user, to: :helpers

  def initialize(f)
    @f = f
  end

  private

    def document
      f.object
    end

    def document_attachment_file_name
      document.attachment_file_name
    end

    def render_destroy_document_link
      if !document.persisted? && document.cached_attachment.present?
        link_to t("documents.form.delete_button"),
          direct_upload_destroy_path(
            "direct_upload[resource_type]": document.documentable_type,
            "direct_upload[resource_id]": document.documentable_id,
            "direct_upload[resource_relation]": "documents",
            "direct_upload[cached_attachment]": document.cached_attachment
          ),
          method: :delete,
          remote: true,
          class: "delete remove-cached-attachment"
      else
        link_to_remove_association document.new_record? ? t("documents.form.cancel_button") : t("documents.form.delete_button"), f, class: "delete remove-document"
      end
    end

    def render_attachment
      klass = document.persisted? || document.cached_attachment.present? ? " hide" : ""
      f.file_field :attachment,
        label_options: { class: "button hollow #{klass}" },
        accept: accepted_content_types_extensions,
        class: "js-document-attachment",
        data: {
          url: document_direct_upload_path,
          nested_document: true
        }
    end

    def document_direct_upload_path
      direct_uploads_path("direct_upload[resource_type]": document.documentable_type,
                          "direct_upload[resource_id]": document.documentable_id,
                          "direct_upload[resource_relation]": "documents")
    end

    def accepted_content_types_extensions
      Setting.accepted_content_types_for("documents").map { |content_type| ".#{content_type}" }.join(",")
    end
end
