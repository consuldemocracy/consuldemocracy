class CensusCaller

  def call(document_type, document_number)
    if Setting["feature.remote_census"].present?
      response = CustomCensusApi.new.call(document_type, document_number)
    else
      response = CensusApi.new.call(document_type, document_number)
    end
    response = LocalCensus.new.call(document_type, document_number) unless response.valid?

    response
  end
end
