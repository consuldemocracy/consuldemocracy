module DocumentsHelper

  def document_attachment_file_name(document)
    document.attachment.attachment_file_name if document.attachment.exists?
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

end
