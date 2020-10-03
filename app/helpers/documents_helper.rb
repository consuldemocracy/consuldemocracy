module DocumentsHelper
  def document_attachment_file_name(document)
    document.attachment_file_name
  end

  def document_errors_on_attachment(document)
    document.errors[:attachment].join(", ") if document.errors.key?(:attachment)
  end

  def render_destroy_document_link(builder, document)
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
      link_to_remove_association document.new_record? ? t("documents.form.cancel_button") : t("documents.form.delete_button"), builder, class: "delete remove-document"
    end
  end

  def render_attachment(builder, document)
    klass = document.persisted? || document.cached_attachment.present? ? " hide" : ""
    builder.file_field :attachment,
                       label_options: { class: "button hollow #{klass}" },
                       accept: accepted_content_types_extensions(document.documentable_type.constantize),
                       class: "js-document-attachment",
                       data: {
                         url: document_direct_upload_path(document),
                         nested_document: true
                       }
  end

  def document_direct_upload_path(document)
    direct_uploads_path("direct_upload[resource_type]": document.documentable_type,
                        "direct_upload[resource_id]": document.documentable_id,
                        "direct_upload[resource_relation]": "documents")
  end

  def document_item_link(document)
    info_text = "#{document.humanized_content_type} | #{number_to_human_size(document.attachment_file_size)}"

    link_to safe_join([document.title, tag.small("(#{info_text})")], " "),
            document.attachment.url,
            target: "_blank",
            title: t("shared.target_blank")
  end
end
