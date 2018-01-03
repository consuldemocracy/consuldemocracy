class CensusCaller

  def call(document_type, document_number, user)
    response = CensusApi.new.call(document_type, document_number, user)
    Rails.logger.info response
    #response = LocalCensus.new.call(document_type, document_number) unless response.valid?

    response
  end
end
