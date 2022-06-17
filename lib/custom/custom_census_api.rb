require "csv"

class CustomCensusApi

  def call(document_type, document_number, postal_code)
    return Response.new(nil, nil) unless Rails.env.production? || Rails.env.staging?

    response = Response.new(nil, nil)
    entities = census_entities_codes(postal_code)

    Rails.logger.info("[Census WS] Postal code #{postal_code} matches with entities: #{entities}")

    entities.each do |entity_code|
      nonce = 18.times.map { rand(10) }.join
      response = Response.new(
        get_response_body(document_type, document_number, nonce, entity_id(entity_code)),
        nonce
      )
      response.geozone_external_code = census_geozone_external_code(entity_code)

      break if response.is_citizen?
    end

    response
  end

  def census_entities_codes(postal_code)
    CENSUS_DICTIONARY[postal_code] || []
  end

  def census_geozone_external_code(entity_code)
    GEOZONES_DICTIONARY[entity_code]
  end

  def entity_id(id)
    Rails.env.development? ? 999 : id
  end

  class Response

    attr_accessor(
      :sml_message,
      :request_nonce,
      :response_nonce,
      :census_birth_time,
      :census_date_of_birth,
      :census_age,
      :geozone_external_code
    )

    def initialize(body, request_nonce)
      return unless Rails.env.production? || Rails.env.staging?

      return unless body.present? && request_nonce.present?

      self.request_nonce = request_nonce
      self.sml_message = Nokogiri::XML(Nokogiri::XML(body).at_css("servicioReturn"))
      log("response SML message:\n#{sml_message}")

      self.response_nonce = sml_message.at_css("nonce")&.content

      if successful_request? && is_citizen?
        self.census_birth_time = Time.parse(sml_message.at_css("fechaNacimiento")&.content)
        self.census_date_of_birth = census_birth_time.to_date
        self.census_age = ((Time.zone.now - census_birth_time) / 1.year.seconds).floor
      end
    end

    def valid?
      return true unless Rails.env.production? || Rails.env.staging?

      return false unless sml_message.present?

      unless successful_request?
        log("Request was not successful")
        return false
      end

      unless request_nonce == response_nonce
        log("Nonce does not match")
        return false
      end

      true
    end

    def successful_request?
      sml_message.at_css("exito")&.content == "-1"
    end

    def is_citizen?
      sml_message.at_css("isHabitante")&.content == "-1"
    end

    private

    def log(message)
      Rails.logger.info("[Census WS] #{message}")
    end
  end

  private

  def get_response_body(document_type, document_number, nonce, municipality_id)
    date = current_date
    request_body = build_request_body(date, nonce, encoded_token(nonce, date), document_type, document_number, municipality_id)
    make_request(request_body)
  end

  def make_request(request_body)
    RestClient.post(
      census_host,
      request_body,
      { content_type: "text/xml; charset=utf-8", SOAPAction: census_host }
    )
  end

  def build_request_body(date, nonce, token, document_type, document_number, municipality_id)
    encoded_document_number = Base64.encode64(document_number).delete("\n")

    sml_message = Rack::Utils.escape_html(
      "<E>\n\t<OPE>\n\t\t<APL>PAD</APL>\n\t\t<TOBJ>HAB</TOBJ>\n\t\t<CMD>ISHABITANTE</CMD>"\
      "\n\t\t<VER>2.0</VER>\n\t</OPE>\n\t<SEC>\n\t\t<CLI>ACCEDE</CLI>\n\t\t"\
      "<ORG>#{municipality_id}</ORG>\n\t\t"\
      "<ENT>#{municipality_id}</ENT>"\
      "\n\t\t<USU>" + census_user + "</USU>\n\t\t<PWD>" + encoded_census_password + "</PWD>\n\t\t<FECHA>" + date + "</FECHA>\n\t\t<NONCE>" + nonce + "</NONCE>"\
      "\n\t\t<TOKEN>" + token + "</TOKEN>\n\t</SEC>\n\t<PAR>\n\t\t<nia></nia>\n\t\t<codigoTipoDocumento>" + document_type.to_s + "</codigoTipoDocumento>"\
      "\n\t\t<documento>" + encoded_document_number + "</documento>\n\t\t<mostrarFechaNac>-1</mostrarFechaNac>\n\t</PAR>\n</E>"
    )

    body = "<?xml version=\"1.0\" encoding=\"utf-8\"?>"
    body += "<SOAP-ENV:Envelope xmlns:SOAP-ENV=\"http://schemas.xmlsoap.org/soap/envelope/\" SOAP-ENV:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">"
    body += "<SOAP-ENV:Body>"
    body += "<m:servicio xmlns:m=\"" + census_host + "\"><sml>#{sml_message}</sml></m:servicio>"
    body += "</SOAP-ENV:Body></SOAP-ENV:Envelope>"

    body
  end

  def census_host
    Rails.application.secrets.padron_host
  end

  def census_user
    Rails.application.secrets.padron_user
  end

  def current_date
    Time.now.strftime("%Y%m%d%H%M%S")
  end

  def encoded_token(nonce, date)
    Digest::SHA512.base64digest(nonce + date + Rails.application.secrets.padron_public_key)
  end

  def encoded_census_password
    Digest::SHA1.base64digest(Rails.application.secrets.padron_password)
  end

  def log(message)
    Rails.logger.info("[Census WS] #{message}") unless Rails.env.production?
  end

end
