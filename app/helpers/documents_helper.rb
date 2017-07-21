module DocumentsHelper

  def document_attachment_file_name(document)
    document.attachment.attachment_file_name if document.attachment.exists?
  end

  def errors_on_attachment(document)
    document.errors[:attachment].join(', ') if document.errors.key?(:attachment)
  end

  def document_documentable_class(document)
    document.documentable.class.name.parameterize('_')
  end

end