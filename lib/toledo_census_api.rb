include DocumentParser

# REQUIREMENT TOL-2: Custom Census verification model and API integration to use custom Toledo's service
class ToledoCensusApi < CensusApi
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
      @census_response = body
    end

    def valid?
      @census_response[:error].nil?
    end

    def gender
      @census_response['Gender']
    end

    def name
      "#{@census_response['Nombre']} #{@census_response['PrimerApellido']} #{@census_response['SegundoApellido']}"
    end

    def date_of_birth
      str = @census_response['FechaNacimiento']
      day, month, year = str.match(/(\d\d\d?\d?)\D(\d\d?)\D(\d\d?)/)[1..3]
      return nil unless day.present? && month.present? && year.present?
      Date.new(day.to_i, month.to_i, year.to_i)
    end

    def postal_code
      @census_response['CP']
    end

    def district_code
      @census_response['Barrio_id']
    end

  end

  def get_response_body(document_type, document_number)
    if end_point_available?
      begin
        @parsed_to_json = JSON.parse(rest_client_response(document_number))
        @census_response = @parsed_to_json.kind_of?(Array)? @parsed_to_json[0] : @parsed_to_json
      rescue Exception => ex

        @census_response = { error: { code: 404, message: ex.message } }
      end
      @census_response
    else
      stubbed_response(document_type, document_number)
    end
  end

  def rest_client_response(document_number)
    RestClient.get "#{Rails.application.secrets.census_api_endpoint}#{document_number}",
                   Rails.application.secrets.census_x_key => Rails.application.secrets.census_api_key

  end

  def end_point_available?
    Rails.env.staging? || Rails.env.preproduction? || Rails.env.production?
  end

  def stubbed_response(document_type, document_number)

    if document_number == "12345678" && document_type == "1"
      stubbed_valid_response
    else
      stubbed_invalid_response
    end
  end

  def stubbed_valid_response
    {
      'IDHAB' => '111111',
      'DNI' => '12345678Z',
      'Nombre' => 'Doménikos',
      'PrimerApellido' => 'Theotokópoulo',
      'SegundoApellido' => 'ElGreco',
      'FechaNacimiento' => '1980-12-31 00:00:00',
      'Telefono' => '666666666',
      'Barrio' => 'CENTRO',
      'Barrio_ID'=> '08',
      'CP' => '45003'
    }
  end

  def stubbed_invalid_response
    {
      error:
        {
          code: 404,
          message: '404 Not Found'
        }
    }
  end
end
