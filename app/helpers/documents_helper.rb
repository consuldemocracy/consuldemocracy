module DocumentsHelper

  def document_note(document)
    t "documents.new.#{document.documentable.class.name.parameterize.underscore}.note",
      title: document.documentable.title
  end

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
              class: "delete remove-document"
    elsif !document.persisted? && document.cached_attachment.present?
      link_to t('documents.form.delete_button'),
                  direct_upload_destroy_url("direct_upload[resource_type]": document.documentable_type,
                                            "direct_upload[resource_id]": document.documentable_id,
                                            "direct_upload[resource_relation]": "documents",
                                            "direct_upload[cached_attachment]": document.cached_attachment),
                  method: :delete,
                  remote: true,
                  class: "delete remove-cached-attachment"
    else
      link_to t('documents.form.delete_button'),
              "#",
              class: "delete remove-nested-field"
    end
  end

  def render_attachment(document, index)
    html = file_field_tag :attachment,
                          accept: accepted_content_types_extensions(document.documentable_type.constantize),
                          class: 'js-document-attachment',
                          data: {
                            url: document_direct_upload_url(document),
                            cached_attachment_input_field: document_nested_field_id(document, index, :cached_attachment),
                            title_input_field: document_nested_field_id(document, index, :title),
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
    direct_uploads_url("direct_upload[resource_type]": document.documentable_type,
                       "direct_upload[resource_id]": document.documentable_id,
                       "direct_upload[resource_relation]": "documents")
  end

end
