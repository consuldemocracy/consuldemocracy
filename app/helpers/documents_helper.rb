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

  def document_nested_field_name(document, index, field)
    parent = document.documentable_type.parameterize.underscore
    "#{parent.parameterize}[documents_attributes][#{index}][#{field}]"
  end

  def document_nested_field_id(document, index, field)
    parent = document.documentable_type.parameterize.underscore
    "#{parent.parameterize}_documents_attributes_#{index}_#{field}"
  end

  def document_nested_field_wrapper_id(index)
    "document_#{index}"
  end

  def render_destroy_document_link(document, index)
    if document.persisted?
      link_to t('documents.form.delete_button'),
              document_path(document, index: index, nested_document: true),
              method: :delete,
              remote: true,
              data: { confirm: t('documents.actions.destroy.confirm') },
              class: "delete float-right"
    elsif !document.persisted? && document.cached_attachment.present?
      link_to t('documents.form.delete_button'),
              destroy_upload_documents_path(path: document.cached_attachment,
                                            nested_document: true,
                                            index: index,
                                            documentable_type: document.documentable_type,
                                            documentable_id: document.documentable_id),
              method: :delete,
              remote: true,
              class: "delete float-right"
    else
      link_to t('documents.form.delete_button'),
              "#",
              class: "delete float-right remove-document"
    end
  end

  def render_attachment(document, index)
    html = file_field_tag :attachment,
                          accept: accepted_content_types_extensions(document.documentable_type.constantize),
                          class: 'js-document-attachment',
                          data: {
                            url: document_direct_upload_url(document),
                            cached_attachment_input_field: document_nested_field_id(document, index, :cached_attachment),
                            multiple: false,
                            index: index,
                            nested_document: true
                          },
                          name: document_nested_field_name(document, index, :attachment),
                          id: document_nested_field_id(document, index, :attachment)
    if document.attachment.blank? && document.cached_attachment.blank?
      klass = document.errors[:attachment].any? ? "error" : ""
      html += label_tag document_nested_field_id(document, index, :attachment),
                       t("documents.form.attachment_label"),
                       class: "button hollow #{klass}"
      if document.errors[:attachment].any?
        html += content_tag :small, class: "error" do
          document_errors_on_attachment(document)
        end
      end
    end
    html
  end

  def document_direct_upload_url(document)
    upload_documents_url(
      documentable_type: document.documentable_type,
      documentable_id: document.documentable_id,
      format: :js
    )
  end

end
