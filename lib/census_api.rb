class CensusApi

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

    if is_dni?(document_type)
      # If a letter exists at the end, delete it and put it on the letter var
      letter = document_number.last
      if letter[/[A-Za-z]/] == letter
        document_number = document_number[0..-2]
      else
        letter = nil
      end

      document_number = document_number.last(8) # Keep only the last x digits
      document_number = document_number.gsub(/^0+/, '') # Removes leading zeros

      # if the number has less digits than it should, pad with zeros to the left and add each variant to the list
      # For example, if the initial document_number is 1234, possible numbers should have
      # [1234, 01234, 001234, 0001234]
      possible_numbers = []
      possible_numbers << document_number unless document_number.blank?
      while document_number.size < 8
        document_number = "0#{document_number}"
        possible_numbers << document_number
      end

      variants += possible_numbers

      # if a letter was given, try the numbers followed by the letter in upper and lowercase
      if letter.present? then
        possible_numbers.each do |number|
          variants << number + letter.downcase << number + letter.upcase
        end
      end
    else # not a DNI
      variants << document_number
    end

    variants
  end

  class Response
    def initialize(body)
      @body = body
    end

    def valid?
      data[:datos_habitante][:item].present?
    end

    def date_of_birth
      data[:datos_habitante][:item][:fecha_nacimiento_string]
    end

    def postal_code
      data[:datos_vivienda][:item][:codigo_postal]
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
        stubbed_response_body
      end
    end

    def client
      @client = Savon.client(wsdl: Rails.application.secrets.census_api_end_point)
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

    def stubbed_response_body
      {:get_habita_datos_response=>{:get_habita_datos_return=>{:hay_errores=>false, :datos_habitante=>{:item=>{:fecha_nacimiento_string=>"31-12-1980", :identificador_documento=>"12345678Z", }}, :datos_vivienda=>{:item=>{:codigo_postal=>"28013"}}}}}
    end

    def is_dni?(document_type)
      document_type.to_s == "1"
    end
end
