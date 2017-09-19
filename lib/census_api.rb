include DocumentParser

class CensusApi

  def call(document_type, document_number)
    response = nil
    get_document_number_variants(document_type, document_number).each do |variant|
      response = Response.new(get_response_body(document_type, variant))
      Rails.logger.info response
      Rails.logger.info "valid" if response.valid?
      return response if response.valid?
    end
    Rails.logger.info "invalid" 
    response
  end

  class Response
    def initialize(body)
      @body = body
    end

    def valid?
      data.class == Hash  && [:last_order].present?
    end

    def date_of_birth
      nil
    end

    def postal_code
      data["billing"]["postcode"]
    end

    def district_code
      nil#nil#nil#data["billing"]["postcode"]
    end

    def gender
      nil
    end

    def name
      "#{data['first_name']} #{data['last_name']}"
    end

    private

      def data
        @body#[:get_habita_datos_response][:get_habita_datos_return]
      end
  end

  private

    def get_response_body(document_type, document_number)
      Rails.logger.info  "get_response_body"
      all  = client.get("customers?per_page=100").parsed_response #client.call(:get_habita_datos, message: request(document_type, document_number)).bodyi
      all.each do |a|
        Rails.logger.info document_number.to_s
        Rails.logger.info  a["billing"]["company"].to_s
        if document_number.to_s ==  a["billing"]["company"].to_s
          Rails.logger.info a
          return a
        end
      end
    end

    def client
      #@client = Savon.client(wsdl: Rails.application.secrets.census_api_end_point)


      @client = WooCommerce::API.new(
        "http://www.kolhaam.org.il",
        "ck_1ef0696d317d1272b2d3fa3152f50155ad72ecb5",
        "cs_778561b003ad3bd565428e3ffea465de7a65136b",
        {
          wp_api: true,
          version: "wc/v1",
         verify_ssl: false 
        }
      )
    end

    def request(document_type, document_number)
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

    def stubbed_response(document_type, document_number)
      if document_number == "12345678Z" && document_type == "1"
        stubbed_valid_response
      else
        stubbed_invalid_response
      end
    end

    def stubbed_valid_response
      {
        get_habita_datos_response: {
          get_habita_datos_return: {
            datos_habitante: {
              item: {
                fecha_nacimiento_string: "31-12-1980",
                identificador_documento: "12345678Z",
                descripcion_sexo: "Varón",
                nombre: "José",
                apellido1: "García"
              }
            },
            datos_vivienda: {
              item: {
                codigo_postal: "28013",
                codigo_distrito: "01"
              }
            }
          }
        }
      }
    end

    def stubbed_invalid_response
      {get_habita_datos_response: {get_habita_datos_return: {datos_habitante: {}, datos_vivienda: {}}}}
    end

    def is_dni?(document_type)
      false #document_type.to_s == "1"
    end

end
