class CensusApi
  attr_accessor :client, :citizen, :response

  def initialize(citizen)
    @citizen = citizen
  end

  def client
    @client = Savon.client(wsdl: Rails.application.secrets.census_api_end_point)
  end

  def response
    return stubbed_response unless end_point_available?
    client.call(:get_habita_datos, message: request).body
  end

  def request
    { request:
      { codigo_institucion: Rails.application.secrets.census_api_institution_code,
        codigo_portal:      Rails.application.secrets.census_api_portal_name,
        codigo_usuario:     Rails.application.secrets.census_api_user_code,
        documento:          citizen.document_number,
        tipo_documento:     citizen.document_type,
        codigo_idioma:      102,
        nivel: 3 }}
  end

  def data
    response[:get_habita_datos_response][:get_habita_datos_return]
  end

  def date_of_birth
    data[:datos_habitante][:item][:fecha_nacimiento_string]
  end

  def postal_code
    data[:datos_vivienda][:item][:codigo_postal]
  end

  def address
    response[:get_habita_datos_response][:get_habita_datos_return][:datos_vivienda][:item]
  end

  def valid?
    return false unless data[:datos_habitante][:item].present?

    citizen.date_of_birth == date_of_birth &&
    citizen.postal_code   == postal_code
  end

  def end_point_available?
    Rails.env.staging? || Rails.env.preproduction? || Rails.env.production?
  end

  def stubbed_response
    {:get_habita_datos_response=>{:get_habita_datos_return=>{:hay_errores=>false, :datos_habitante=>{:item=>{:fecha_nacimiento_string=>"31-12-1980", :identificador_documento=>"12345678Z", }}, :datos_vivienda=>{:item=>{:codigo_postal=>"28013", :escalera=>"4", :km=>"0", :letra_via=>"B", :nombre_barrio=>"JUSTICIA", :nombre_distrito=>"CENTRO", :nombre_via=>"ALCALÁ", :nominal_via=>"NUM", :numero_via=>"1", :planta=>"PB", :portal=>"1", :puerta=>"DR", :sigla_via=>"CALLE"}}}}}
  end
end
