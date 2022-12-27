class CensusCaller

  def call(document_type, document_number, postal_code)
    document_number = DocumentParser.format_residence_card(document_number) if document_type.to_s == "3"

    response = CustomCensusApi.new.call(document_type, document_number, postal_code)
    return response if response.valid? && response.is_citizen?

    CustomCensusApi.new.call(nil, document_number, postal_code)
  end

end
