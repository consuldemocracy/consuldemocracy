require "csv"

class CensusApi

  def call(document_type, document_number, postal_code)
    response = Response.new
    entities = census_entities_codes(postal_code)

    Rails.logger.info("[Census WS] Postal code #{postal_code} matches with entities: #{entities}")

    entities.each do |entity_code|
      nonce = 18.times.map { rand(10) }.join
      response = Response.new(
        get_response_body(document_type, document_number, nonce, postal_code, entity_code),
        nonce
      )

      break if response&.is_habitante != "0"
    end

    response
  end

  def census_entities_codes(postal_code)
    CENSUS_DICTIONARY[postal_code] || []
  end

  class Response
    def initialize(body = nil, nonce = nil)
      @data = body ? Nokogiri::XML(Nokogiri::XML(body).at_css("servicioReturn")) : nil
      @nonce = nonce
    end

    def valid?
      return false unless @data.present?

      recibimosValid = "" + @data

      if recibimosValid.include? "recibido SML"
        edad = 0
      elsif recibimosValid.include? "Es repetido"
        edad = 0
      elsif recibimosValid.include? "integridad"
        edad = 0
      elsif recibimosValid.include? "La Organiza"
        edad = 0
      else
        fechaActual = Time.now.strftime("%Y%m%d%H%M%S")
        fechaActualNumeric = BigDecimal.new(fechaActual);
        fechaNacimientoNumeric = BigDecimal.new(date_of_birth);
        edad = fechaActualNumeric-fechaNacimientoNumeric
      end

      (exito == "-1") && (response_nonce == @nonce) && (is_habitante == "-1") && (edad >= 160_000_000_000)
    end

    def exito
      @data.at_css("exito").content
    end

    def response_nonce
      @data.at_css("nonce").content
    end

    def is_habitante
      recibimosHabitante = "" + @data
      if recibimosHabitante.include? 'recibido SML'
        # no hacemos nada. El usuario no corresponde a ningún padrón de la diputación
        puts "No es usuario- SML"
      elsif recibimosHabitante.include? 'Es repetido'
        puts "No es usuario - repetido"
      elsif recibimosHabitante.include? 'integridad'
        puts "No es usuario- integridad"
      elsif recibimosHabitante.include? 'La Organiza'
        puts "No es usuario- La organización no existe"
      else
        @data.at_css("isHabitante").content
      end
    end

    def date_of_birth
      recibimos = "" + @data

      if recibimos.include? 'recibido SML'
        # no hacemos nada. El usuario no corresponde a ningún padrón de la diputación
        puts "No es usuario-SML"
      elsif recibimos.include? 'Es repetido'
        puts "No es usuario-REPETIDO"
      elsif recibimos.include? 'integridad'
        puts "No es usuario-integridad"
      elsif recibimos.include? 'La Organizac'
        puts "No es usuario- La organización no existe"
      else
        @data.at_css("fechaNacimiento").content
      end
    end

    def document_number
      Base64.decode64 (@data.at_css("documento").content)
    end
  end

  private

  def get_response_body(document_type, document_number, nonce, postal_code, municipality_id)
    date = current_date
    request_body = build_request_body(date, nonce, encoded_token(nonce, date), document_number, municipality_id)

    log("Request: #{request_body}")

    response = make_request(request_body)

    log("Response: #{response}")

    response
  end

  def make_request(request_body)
    RestClient.post(
      census_host,
      request_body,
      { content_type: "text/xml; charset=utf-8", SOAPAction: census_host }
    )
  end

  def build_request_body(date, nonce, token, document_number, municipality_id)
    encoded_document_number = Base64.encode64(document_number).delete("\n")

    sml_message = Rack::Utils.escape_html(
      "<E>\n\t<OPE>\n\t\t<APL>PAD</APL>\n\t\t<TOBJ>HAB</TOBJ>\n\t\t<CMD>ISHABITANTE</CMD>"\
      "\n\t\t<VER>2.0</VER>\n\t</OPE>\n\t<SEC>\n\t\t<CLI>ACCEDE</CLI>\n\t\t"\
      "<ORG>#{municipality_id}</ORG>\n\t\t"\
      "<ENT>#{municipality_id}</ENT>"\
      "\n\t\t<USU>" + census_user + "</USU>\n\t\t<PWD>" + encoded_census_password + "</PWD>\n\t\t<FECHA>" + date + "</FECHA>\n\t\t<NONCE>" + nonce + "</NONCE>"\
      "\n\t\t<TOKEN>" + token + "</TOKEN>\n\t</SEC>\n\t<PAR>\n\t\t<nia></nia>\n\t\t<codigoTipoDocumento>1</codigoTipoDocumento>"\
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
