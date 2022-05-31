require_dependency Rails.root.join("lib", "document_parser").to_s

module DocumentParser
  def dni?(document_type)
    document_type.to_s == "D"
  end
end
