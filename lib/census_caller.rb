class CensusCaller

  def call(document_type, document_number, tenant = Tenant.find_by(subdomain: Apartment::Tenant.current))
    response = CensusApi.new(tenant).call(document_type, document_number)
    response = LocalCensus.new.call(document_type, document_number) unless response.valid?

    response
  end
end
