class CensusCaller

  def call(document_type, document_number, postal_code)
    response = CensusvaApi.new.call(document_type, document_number, postal_code)
    response = LocalCensus.new.call(document_type, document_number) unless response.valid?

    response
  end

  def call(document_type, document_number)
    response = CensusApi.new.call(document_type, document_number)
    response = LocalCensus.new.call(document_type, document_number) unless response.valid?

    response
  end
end
