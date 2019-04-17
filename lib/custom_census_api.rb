include DocumentParser
class CustomCensusApi

  def call(document_type, document_number, date_of_birth, postal_code)
    response = nil
    get_document_number_variants(document_type, document_number).each do |variant|
      response = Response.new(get_response_body(document_type, variant, date_of_birth, postal_code))
      return response if response.valid?
    end
    response
  end

  class Response
    def initialize(body)
      @body = body
    end

    def extract_value(alias_value)
      path = parse_alias(alias_value)
      return nil unless path.present?
      @body.dig(*path)
    end

    def valid?
      alias_valid = Setting["remote_census_response.valid"]
      extract_value(alias_valid).present?
    end

    def date_of_birth
      alias_date_of_birth = Setting["remote_census_response.date_of_birth"]
      str = extract_value(alias_date_of_birth)
      return nil unless str.present?
      day, month, year = str.match(/(\d\d?)\D(\d\d?)\D(\d\d\d?\d?)/)[1..3]
      return nil unless day.present? && month.present? && year.present?
      Time.zone.local(year.to_i, month.to_i, day.to_i).to_date
    end

    def postal_code
      alias_postal_code = Setting["remote_census_response.postal_code"]
      extract_value(alias_postal_code)
    end

    def district_code
      alias_district = Setting["remote_census_response.district"]
      extract_value(alias_district)
    end

    def gender
      alias_gender = Setting["remote_census_response.gender"]

      case extract_value(alias_gender)
      when "Varón"
        "male"
      when "Mujer"
        "female"
      end
    end

    def name
      alias_name = Setting["remote_census_response.name"]
      alias_surname = Setting["remote_census_response.surname"]

      "#{extract_value(alias_name)} #{extract_value(alias_surname)}"
    end

    def parse_alias(alias_value)
      alias_value.split(".").map{ |section| section.to_sym } if alias_value.present?
    end
  end

  private

    def get_response_body(document_type, document_number, date_of_birth, postal_code)
      if end_point_available?
        client.call(Setting["remote_census_request.method_name"].to_sym, message: request(document_type, document_number, date_of_birth, postal_code)).body
      else
        stubbed_response(document_type, document_number)
      end
    end

    def client
      @client = Savon.client(wsdl: Setting["remote_census_general.endpoint"])
    end

    def request(document_type, document_number, date_of_birth, postal_code)
      structure = eval(Setting["remote_census_request.structure"])

      fill_in(structure, Setting["remote_census_request.alias_document_type"], document_type)
      fill_in(structure, Setting["remote_census_request.alias_document_number"], document_number)
      fill_in(structure, Setting["remote_census_request.alias_postal_code"], postal_code)
      if date_of_birth.present?
        fill_in(structure, Setting["remote_census_request.alias_date_of_birth"], I18n.l(date_of_birth, format: :default))
      end

      structure
    end

    def fill_in(structure, alias_value, value)
      path = parse_alias(alias_value)

      update_value(structure, path, value) if path.present?
    end

    def parse_alias(alias_value)
      alias_value.split(".").map{ |section| section.to_sym } if alias_value.present?
    end

    def update_value(structure, path, value)
      *path, final_key = path
      to_set = path.empty? ? structure : structure.dig(*path)

      return unless to_set
      to_set[final_key] = value
    end

    def end_point_available?
      Rails.env.staging? || Rails.env.preproduction? || Rails.env.production?
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
      {get_habita_datos_response: {get_habita_datos_return: {datos_habitante: {}, datos_vivienda: {}}}}
    end

end
