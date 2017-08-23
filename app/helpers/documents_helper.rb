module DocumentsHelper

  def document_attachment_file_name(document)
    document.attachment_file_name
  end

  def errors_on_attachment(document)
    document.errors[:attachment].join(', ') if document.errors.key?(:attachment)
  end

  def document_source_options
    Hash[Document.sources.map { |k,v| [k, Document.human_attribute_name("document.#{k}")] }]
  end

  def document_link_url(document)
    uri = URI.parse(document.link)
    return document.link if uri.scheme == "http" || uri.scheme == "https"
    "http://#{document.link}"
  end

  def bytesToMeg(bytes)
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

end
