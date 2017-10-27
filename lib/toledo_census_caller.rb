
# REQUIREMENT TOL-2: Redefine CensusCaller verification model to use custom Toledo's service
class ToledoCensusCaller

  def call(document_type, document_number)
    response = ToledoCensusApi.new.call(document_type, document_number)
    raise response.inspect unless response.valid?
    response = LocalCensus.new.call(document_type, document_number) unless response.valid?

    response
  end
end
