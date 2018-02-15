class PadronCastellonApi

  def call(document_type, document_number)
    response = nil
    get_document_number_variants(document_type, document_number).each do |variant|
      response = Response.new(get_response_body(document_type, variant))
      return response if response.valid?
    end
    response
  end

  def get_document_number_variants(document_type, document_number)
    # Delete all non-alphanumerics
    document_number = document_number.to_s.gsub(/[^0-9A-Za-z]/i, '')
    variants = []
    numero, letra = split_letter_from(document_number)
    letra = ' ' unless letra.present?
    number_variants = get_number_variants_with_leading_zeroes_from(numero)
    number_variants << document_number
    number_variants.each do |nv|
      variants << { dni: nv, caracterControl: letra }
      variants << { dni: nv, caracterControl: ' ' }
    end
    variants
  end

  class Response

    def initialize(body)
      @body = body
    end

    def valid?
      data[:HABFECNAC].present?
    end

    def date_of_birth
      data[:HABFECNAC].to_date
    end

    def postal_code
      data[:HABCODPOS]
    end

    def district_code
      data[:HABDISTRI]
    end

    def gender
      case data[:ELSEXO]
      when "Varón"
        "male"
      when "Mujer"
        "female"
      end
    end

    private

      def data
        @body
      end
  end

  private

  def get_response_body(document_type, document_hash)
    if end_point_available? && document_hash[:dni].present?
      llamada_padron(document_type, document_hash)
    else
      binding_response(document_hash, stubbed_response(document_type, document_hash))
    end
  end

  def llamada_padron(document_type, document_hash)
    url = Rails.application.secrets.census_api_end_point
    params = { params: document_hash }.merge(header_auth_token)
    default_external_encoding = Encoding.default_external
    Encoding.default_external = Encoding::ISO_8859_1
    response_hash = JSON.parse(RestClient.get(url, params), symbolize_names: true)
    Encoding.default_external = default_external_encoding
    binding_response(document_hash, response_hash)
  end

  def header_auth_token
    auth_token = Base64.urlsafe_encode64(Rails.application.secrets.census_api_user_code)
    {Authorization: "Basic #{auth_token}"}
  end

  def binding_response(document_hash, response_hash)
    ret = {}
    response_hash[:target].each do |rh|
      # return rh if rh[:HABNUMIDE] == document_hash[:dni]
      a = rh[:HABNUMIDE] == document_hash[:dni]
      puts "#{rh[:HABNUMIDE] == document_hash[:dni]}"
      return rh if a
    end
    ret
  end

  def end_point_available?
    Rails.env.staging? || Rails.env.preproduction? || Rails.env.production?
  end

  def stubbed_response(document_type, document_hash)
    if true || document_hash[:dni] == "012345678" && document_hash[:caracterControl] == 'Z' && document_type == "1"
      stubbed_valid_response
    else
      stubbed_invalid_response
    end
  end

  def stubbed_valid_response
    {
      identifier: "1",
      target: [
        {
          HABFECNAC: "1974-06-27 00:00:00.0",
          HABDISTRI: "7",
          ELSEXO: "Varón",
          HABNOMHAB: "MIGUEL",
          HABAP1HAB: "GOMEZ",
          HABAP2HAB: "GUTIERREZ",
          HABNUMIDE: "000000001",
          HABCONDIG: "R",
          HABCODPOS: "12004"
        },
        {
          HABFECNAC: "1976-06-10 00:00:00.0",
          HABDISTRI: "7",
          ELSEXO: "Mujer",
          HABNOMHAB: "ELENA",
          HABAP1HAB: "GARCIA",
          HABAP2HAB: "FORNER",
          HABNUMIDE: "000000002",
          HABCONDIG: "W",
          HABCODPOS: "12004"

        }, {
          HABFECNAC: "1998-08-31 00:00:00.0",
          HABDISTRI: "7",
          ELSEXO: "Varón",
          HABNOMHAB: "ALBERTO",
          HABAP1HAB: "GOMEZ",
          HABAP2HAB: "GARCIA",
          HABNUMIDE: "000000003",
          HABCONDIG: "A",
          HABCODPOS: "12004"
        }, {
          HABFECNAC: "1980-12-31 00:00:00.0",
          HABDISTRI: "7",
          ELSEX: "Varón",
          HABNOMHAB: "JUAN",
          HABAP1HAB: "GOMEZ",
          HABAP2HAB: "GARCIA",
          HABNUMIDE: "012345678",
          HABCONDIG: "Z",
          HABCODPOS: "12004"
        }
      ]
    }
  end

  def stubbed_invalid_response
    {
      identifier: "1",
      target: []
    }
  end

  def is_dni?(document_type)
    document_type.to_s == "1"
  end

  def split_letter_from(document_number)
    letter = document_number.last
    if letter[/[A-Za-z]/] == letter
      document_number = document_number[0..-2]
    else
      letter = nil
    end
    return document_number, letter
  end

  # if the number has less digits than it should, pad with zeros to the left and add each variant to the list
  # For example, if the initial document_number is 1234, and digits=8, the result is
  # ['1234', '01234', '001234', '0001234']
  def get_number_variants_with_leading_zeroes_from(document_number, digits=9)
    document_number = document_number.to_s.last(digits) # Keep only the last x digits
    document_number = document_number.gsub(/^0+/, '')   # Removes leading zeros

    variants = []
    variants << document_number unless document_number.blank?
    while document_number.size < digits
      document_number = "0#{document_number}"
      variants << document_number
    end
    variants
  end

  # Generates uppercase and lowercase variants of a series of numbers, if the letter is present
  # If number_variants == ['1234', '01234'] & letter == 'A', the result is
  # ['1234a', '1234A', '01234a', '01234A']
  def get_letter_variants(number_variants, letter)
    variants = []
    if letter.present? then
      number_variants.each do |number|
        variants << number + letter.downcase << number + letter.upcase
      end
    end
    variants
  end
end
