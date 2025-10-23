class CensusApi
  include DocumentParser

  def call(document_type, document_number)
    response = nil
    get_document_number_variants(document_type, document_number).each do |variant|
      response = Response.new(get_response_body(document_type, variant))
      return response if response.valid?
    end
    response
  end

  class Response
    def initialize(body)
      @body = body
    end

    def valid?
      data[:datos_habitante][:item].present?
    end

    def date_of_birth
      str = data[:datos_habitante][:item][:fecha_nacimiento_string]
      day, month, year = str.match(/(\d\d?)\D(\d\d?)\D(\d\d\d?\d?)/)[1..3]
      return nil if day.blank? || month.blank? || year.blank?

      Time.zone.local(year.to_i, month.to_i, day.to_i).to_date
    end

    def postal_code
      data[:datos_vivienda][:item][:codigo_postal]
    end

    def district_code
      data[:datos_vivienda][:item][:codigo_distrito]
    end

    def gender
      case data[:datos_habitante][:item][:descripcion_sexo]
      when "Varón"
        "male"
      when "Mujer"
        "female"
      end
    end

    def name
      "#{data[:datos_habitante][:item][:nombre]} #{data[:datos_habitante][:item][:apellido1]}"
    end

    private

      def data
        @body[:get_habita_datos_response][:get_habita_datos_return]
      end
  end

  private

    def get_response_body(document_type, document_number)
      if end_point_available?
        client.call(:get_habita_datos, message: request(document_type, document_number)).body
      else
        stubbed_response(document_type, document_number)
      end
    end

    def client
      @client = Savon.client(wsdl: Rails.application.secrets.census_api_end_point)
    end

    def request(document_type, document_number)
      { request:
        { codigo_institucion: Rails.application.secrets.census_api_institution_code,
          codigo_portal: Rails.application.secrets.census_api_portal_name,
          codigo_usuario: Rails.application.secrets.census_api_user_code,
          documento: document_number,
          tipo_documento: document_type,
          codigo_idioma: 102,
          nivel: 3 }}
    end

    def end_point_defined?
      Rails.application.secrets.census_api_end_point.present?
    end

    def end_point_available?
      end_point_defined? && !Rails.env.local?
    end

    def stubbed_response(document_type, document_number)
      if (document_number == "12345678Z" || document_number == "12345678Y") && document_type == "1"
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
      { get_habita_datos_response: { get_habita_datos_return: { datos_habitante: {}, datos_vivienda: {}}}}
    end
end
