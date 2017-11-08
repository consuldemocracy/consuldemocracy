module DocumentsHelper

  def document_attachment_file_name(document)
    document.attachment_file_name
  end

  def document_errors_on_attachment(document)
    document.errors[:attachment].join(', ') if document.errors.key?(:attachment)
  end

  def bytes_to_mega(bytes)
    bytes / Numeric::MEGABYTE
  end

  def document_nested_field_wrapper_id(index)
    "document_#{index}"
  end

  def render_destroy_document_link(builder, document)
    if !document.persisted? && document.cached_attachment.present?
      link_to t('documents.form.delete_button'),
                  direct_upload_destroy_url("direct_upload[resource_type]": document.documentable_type,
                                            "direct_upload[resource_id]": document.documentable_id,
                                            "direct_upload[resource_relation]": "documents",
                                            "direct_upload[cached_attachment]": document.cached_attachment),
                  method: :delete,
                  remote: true,
                  class: "delete remove-cached-attachment"
    else
      link_to_remove_association t('documents.form.delete_button'), builder, class: "delete remove-document"
    end
  end

  def render_attachment(builder, document)
    klass = document.errors[:attachment].any? ? "error" : ""
    klass = document.persisted? || document.cached_attachment.present? ? " hide" : ""
    html = builder.label :attachment,
                         t("documents.form.attachment_label"),
                         class: "button hollow #{klass}"
    html += builder.file_field :attachment,
                               label: false,
                               accept: accepted_content_types_extensions(document.documentable_type.constantize),
                               class: 'js-document-attachment',
                               data: {
                                 url: document_direct_upload_url(document),
                                 nested_document: true
                               }
    html
  end

  def document_direct_upload_url(document)
    direct_uploads_url("direct_upload[resource_type]": document.documentable_type,
                       "direct_upload[resource_id]": document.documentable_id,
                       "direct_upload[resource_relation]": "documents")
  end

  def document_item_link(document)
    link_to "#{document.title} <small>(#{document.humanized_content_type} | \
             #{number_to_human_size(document.attachment_file_size)}</small>)".html_safe,
             document.attachment.url,
             target: "_blank",
             title: t("shared.target_blank_html")
  end
end
