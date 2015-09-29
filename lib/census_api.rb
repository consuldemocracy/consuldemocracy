class CensusApi
  attr_accessor :document_type, :document_number

  def initialize(document_type, document_number)
    @document_type = document_type
    @document_number = document_number
  end

  def call
    Response.new(get_response_body)
  end

  class Response
    def initialize(body)
      @body = body
    end

    def date_of_birth
      data[:datos_habitante][:item][:fecha_nacimiento_string]
    end

    def postal_code
      data[:datos_vivienda][:item][:codigo_postal]
    end

    def valid?
      data[:datos_habitante][:item].present?
    end

    private

      def data
        @body[:get_habita_datos_response][:get_habita_datos_return]
      end
  end

  private

    def get_response_body
      if end_point_available
        client.call(:get_habita_datos, message: request).body
      else
        stubbed_response_body
      end
    end

    def client
      @client = Savon.client(wsdl: Rails.application.secrets.census_api_end_point)
    end

    def request
      { request:
        { codigo_institucion: Rails.application.secrets.census_api_institution_code,
          codigo_portal:      Rails.application.secrets.census_api_portal_name,
          codigo_usuario:     Rails.application.secrets.census_api_user_code,
          documento:          document_number,
          tipo_documento:     document_type,
          codigo_idioma:      102,
          nivel: 3 }}
    end

    def end_point_available?
      Rails.env.staging? || Rails.env.preproduction? || Rails.env.production?
    end

    def stubbed_response_body
      {:get_habita_datos_response=>{:get_habita_datos_return=>{:hay_errores=>false, :datos_habitante=>{:item=>{:fecha_nacimiento_string=>"31-12-1980", :identificador_documento=>"12345678Z", }}, :datos_vivienda=>{:item=>{:codigo_postal=>"28013"}}}}}
    end
end
