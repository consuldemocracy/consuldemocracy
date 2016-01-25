class Census
  include ActionView::Helpers::SanitizeHelper

  def initialize(data)
    @data = data
  end

  def valid?
    response.xpath("//codiRetorn").text == "01"
  end

  private

  def response
    return @response if defined?(@response)

    response ||= Faraday.post Rails.application.secrets.census_url do |request| 
      request.headers['Content-Type'] = 'text/xml'
      request.body = request_body
    end

    @response ||= Nokogiri::XML(response.body).remove_namespaces!
  end

  def document_type
    case @data.fetch(:document_type).to_sym
    when :dni
      "01"
    when :passport
      "02"
    when :nie
      "03"
    else
      raise "Invalid value for document_type provided"
    end
  end

  def document_number
    @data.fetch(:document_number)
  end

  def postal_code
    @data.fetch(:postal_code)
  end

  def date_of_birth
    @date_of_birth ||= @data.fetch(:date_of_birth).strftime("%Y%m%d")
  end

  def request_body
    @request_body ||= <<EOS
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sch="http://es.bcn.mci.ws/cr/schemas">
   <soapenv:Header/>
   <soapenv:Body>
      <sch:GetPersonaLocalitzaAdrecaRequest>
         <sch:usuari>PAM</sch:usuari>
         <sch:Dades>
           <sch:tipDocument>#{sanitize document_type}</sch:tipDocument>
           <sch:docId>#{sanitize document_number}</sch:docId>
           <sch:codiPostal>#{sanitize postal_code}</sch:codiPostal>
           <sch:dataNaixConst>#{sanitize date_of_birth}</sch:dataNaixConst>
         </sch:Dades>
      </sch:GetPersonaLocalitzaAdrecaRequest>
   </soapenv:Body>
</soapenv:Envelope>
EOS
  end
end
