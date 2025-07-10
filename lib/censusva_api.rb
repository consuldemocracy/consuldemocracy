require "securerandom"

class CensusvaApi
  def call(document_type, document_number)
    nonce = Array.new(18).map { SecureRandom.random_number(10) }.join
    Response.new(get_response_body(document_type, document_number, nonce), nonce)
  end

  class Response
    def initialize(body, nonce)
      @data = Nokogiri::XML (Nokogiri::XML(body).at_css("servicioReturn"))
      @nonce = nonce
    end

    def valid?
      (success == "-1") && (response_nonce == @nonce)
    end

    def date_of_birth
      @data.at_css("fechaNacimiento").content.try(&:to_date)
    end

    def postal_code
      Base64.decode64(@data.at_css("codigoPostal").content)
    end

    def district_code
      # Actualmente el padrón no devuelve el código del distrito, se ha dejado el método
      # preparado por si se actualiza en un futuro
      # @data.at_css("codigoDistrito").content.try(&:to_date)
      nil
    end

    def gender
      # Actualmente el padrón no devuelve el género, se ha dejado el método
      # preparado por si se actualiza en un futuro
      # citizen_gender = @data.at_css("genero").content
      citizen_gender = nil

      case citizen_gender
      when "Varón"
        "male"
      when "Mujer"
        "female"
      else
        nil
      end
    end

    def name
      # Actualmente el padrón no devuelve el código del distrito, se ha dejado el método
      # preparado por si se actualiza en un futuro
      # @data.at_css("nombre").content.try(&:to_date)
      nil
    end

    def document_number
      Base64.decode64(@data.at_css("documento").content)
    end

    def success
      @data.at_css("exito").content
    end

    def response_nonce
      @data.at_css("nonce").content
    end
  end

  private

    def codificar(origen)
      Digest::SHA512.base64digest(origen)
    end

    def cod64(entrada)
      Base64.encode64(entrada).delete("\n")
    end

    def get_response_body(document_type, document_number, nonce)
      fecha = Time.zone.now.strftime("%Y%m%d%H%M%S")

      origen = nonce + fecha + Rails.application.secrets.padron_public_key
      token = codificar(origen)

      peticion = "<?xml version=\"1.0\" encoding=\"utf-8\"?>"
      peticion += "<SOAP-ENV:Envelope xmlns:SOAP-ENV=\"http://schemas.xmlsoap.org/soap/envelope/\" SOAP-ENV:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">"
      peticion += "<SOAP-ENV:Body>"
      peticion += "<m:servicio xmlns:m=\"" + Rails.application.secrets.padron_host + "\">"
      peticion += "<sml>"

      peticion += Rack::Utils.escape_html("<E>\n\t<OPE>\n\t\t<APL>PAD</APL>\n\t\t<TOBJ>HAB</TOBJ>\n\t\t<CMD>CONSULTAINDIVIDUAL</CMD>\n\t\t<VER>2.0</VER>\n\t</OPE>\n\t<SEC>\n\t\t<CLI>ACCEDE</CLI>\n\t\t<ORG>0</ORG>\n\t\t<ENT>3</ENT>\n\t\t<EJE></EJE>\n\t\t<UOR></UOR>\n\t\t<USU>CI</USU>\n\t\t<PWD>" + Rails.application.secrets.padron_password + "</PWD>\n\t\t<FECHA>" + fecha + "</FECHA>\n\t\t<NONCE>" + nonce + "</NONCE>\n\t\t<TOKEN>" + token + "</TOKEN>\n\t</SEC>\n\t<PAR>\n\t\t<codigoHabitante></codigoHabitante>\n\t\t<nia></nia>\n\t\t<codigoTipoDocumento>" + document_type + "</codigoTipoDocumento>\n\t\t<documento>" + cod64(document_number) + "</documento>\n\t\t<nombre></nombre>\n\t\t<particula1></particula1>\n\t\t<apellido1></apellido1>\n\t\t<particula2></particula2>\n\t\t<apellido2></apellido2>\n\t\t<fechaNacimiento></fechaNacimiento>\n\t\t<busquedaExacta>-1</busquedaExacta>\n\t</PAR>\n</E>")

      peticion += "</sml>"
      peticion += "</m:servicio>"
      peticion += "</SOAP-ENV:Body></SOAP-ENV:Envelope>"

      respuesta = RestClient.post(Rails.application.secrets.padron_host, peticion, { content_type: "text/xml; charset=utf-8", SOAPAction: Rails.application.secrets.padron_host })

      respuesta
    end
end
