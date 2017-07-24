module DocumentablesHelper

  def documentable_class(documentable)
    documentable.class.name.parameterize('_')
  end

  def max_documents_allowed(documentable)
    documentable.class.max_documents_allowed
  end

  def max_file_size(documentable)
    bytesToMeg(documentable.class.max_file_size)
  end

  def accepted_content_types(documentable)
    documentable.class.accepted_content_types
  end

  def humanized_accepted_content_types(documentable)
    documentable.class.accepted_content_types
                .collect{ |content_type| content_type.split("/").last }
                .join(", ")
  end

end