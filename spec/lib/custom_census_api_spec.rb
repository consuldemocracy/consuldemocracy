require "rails_helper"

describe CustomCensusApi do
  let(:api) { described_class.new }

  describe "#call" do
    let(:invalid_body) { {get_habita_datos_response: {get_habita_datos_return: {datos_habitante: {}}}} }
    let(:valid_body) do
      {
        get_habita_datos_response: {
          get_habita_datos_return: {
            datos_habitante: {
              item: {
                fecha_nacimiento_string: "1-1-1980"
              }
            }
          }
        }
      }
    end

    it "returns the response for the first valid variant" do
      allow(api).to receive(:get_response_body).with(1, "00123456", Date.parse("01/01/1983"), "28001").and_return(invalid_body)
      allow(api).to receive(:get_response_body).with(1, "123456", Date.parse("01/01/1983"), "28001").and_return(invalid_body)
      allow(api).to receive(:get_response_body).with(1, "0123456", Date.parse("01/01/1983"), "28001").and_return(valid_body)

      response = api.call(1, "123456", Date.parse("01/01/1983"), "28001")

      expect(response).to be_valid
      expect(response.date_of_birth).to eq(Date.new(1980, 1, 1))
    end

    it "returns the response for the first valid variant without send date_of_birth and postal_code" do
      allow(api).to receive(:get_response_body).with(1, "00123456", nil, nil).and_return(invalid_body)
      allow(api).to receive(:get_response_body).with(1, "123456", nil, nil).and_return(invalid_body)
      allow(api).to receive(:get_response_body).with(1, "0123456", nil, nil).and_return(valid_body)

      response = api.call(1, "123456", nil, nil)

      expect(response).to be_valid
      expect(response.date_of_birth).to eq(Date.new(1980, 1, 1))
    end

    it "returns the last failed response" do
      allow(api).to receive(:get_response_body).with(1, "00123456", Date.parse("01/01/1983"), "28001").and_return(invalid_body)
      allow(api).to receive(:get_response_body).with(1, "123456", Date.parse("01/01/1983"), "28001").and_return(invalid_body)
      allow(api).to receive(:get_response_body).with(1, "0123456", Date.parse("01/01/1983"), "28001").and_return(invalid_body)
      response = api.call(1, "123456", Date.parse("01/01/1983"), "28001")

      expect(response).not_to be_valid
    end
  end

  describe "request structure correctly filled" do

    before do
      Setting["feature.remote_census"] = true
      Setting["remote_census_request.structure"] = "{ request:
                                                      { codigo_institucion: 1,
                                                        codigo_portal: 1,
                                                        codigo_usuario: 1,
                                                        documento: 'xxx',
                                                        tipo_documento: 'xxx',
                                                        codigo_idioma: '102',
                                                        nivel: '3' }
                                                    }"
      Setting["remote_census_request.alias_document_type"] = "request.tipo_documento"
      Setting["remote_census_request.alias_document_number"] = "request.documento"
      Setting["remote_census_request.alias_date_of_birth"] = nil
      Setting["remote_census_request.alias_postal_code"] = nil
    end

    it "with default values" do
      document_type = "1"
      document_number = "0123456"

      request = CustomCensusApi.new.send(:request, document_type, document_number, nil, nil)

      expect(request).to eq ({:request=>{:codigo_institucion=>1, :codigo_portal=>1, :codigo_usuario=>1, :documento=>"0123456", :tipo_documento=>"1", :codigo_idioma=>"102", :nivel=>"3"}})
    end

    it "when send date_of_birth and postal_code but are not configured" do
      document_type = "1"
      document_number = "0123456"
      date_of_birth =  Date.new(1980, 1, 1)
      postal_code = "28001"

      request = CustomCensusApi.new.send(:request, document_type, document_number, date_of_birth, postal_code)

      expect(request).to eq ({:request=>{:codigo_institucion=>1, :codigo_portal=>1, :codigo_usuario=>1, :documento=>"0123456", :tipo_documento=>"1", :codigo_idioma=>"102", :nivel=>"3"}})
    end

    it "when send date_of_birth and postal_code but are configured" do
      Setting["remote_census_request.structure"] = "{ request:
                                                      { codigo_institucion: 1,
                                                        codigo_portal: 1,
                                                        codigo_usuario: 1,
                                                        documento: 'xxx',
                                                        tipo_documento: 'xxx',
                                                        fecha_nacimiento: 'xxx',
                                                        codigo_postal: 'xxx',
                                                        codigo_idioma: '102',
                                                        nivel: '3' }
                                                    }"
      Setting["remote_census_request.alias_date_of_birth"] = "request.fecha_nacimiento"
      Setting["remote_census_request.alias_postal_code"] = "request.codigo_postal"
      document_type = "1"
      document_number = "0123456"
      date_of_birth =  Date.new(1980, 1, 1)
      postal_code = "28001"

      request = CustomCensusApi.new.send(:request, document_type, document_number, date_of_birth, postal_code)

      expect(request).to eq ({:request=>{:codigo_institucion=>1, :codigo_portal=>1, :codigo_usuario=>1, :documento=>"0123456", :tipo_documento=>"1", :fecha_nacimiento=>"1980-01-01", :codigo_postal=>"28001", :codigo_idioma=>"102", :nivel=>"3"}})
    end

  end

  describe "get_response_body" do

    before do
      Setting["feature.remote_census"] = true
    end

    it "return expected stubbed_response" do
      document_type = "1"
      document_number = "12345678Z"

      response = CustomCensusApi.new.send(:get_response_body, document_type, document_number, nil, nil)

      expect(response).to eq ({ get_habita_datos_response: {
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
                              })
    end

  end

  describe "CustomCensusApi::Response" do

    before do
      Setting["feature.remote_census"] = true
      Setting["remote_census_response.date_of_birth"] = "get_habita_datos_response.get_habita_datos_return.datos_habitante.item.fecha_nacimiento_string"
      Setting["remote_census_response.postal_code"] = "get_habita_datos_response.get_habita_datos_return.datos_vivienda.item.codigo_postal"
      Setting["remote_census_response.district"] = "get_habita_datos_response.get_habita_datos_return.datos_vivienda.item.codigo_distrito"
      Setting["remote_census_response.gender"] = "get_habita_datos_response.get_habita_datos_return.datos_habitante.item.descripcion_sexo"
      Setting["remote_census_response.name"] = "get_habita_datos_response.get_habita_datos_return.datos_habitante.item.nombre"
      Setting["remote_census_response.surname"] = "get_habita_datos_response.get_habita_datos_return.datos_habitante.item.apellido1"
      Setting["remote_census_response.valid"] = "get_habita_datos_response.get_habita_datos_return.datos_habitante.item"
    end

    it "return expected response methods with default values" do
      document_type = "1"
      document_number = "12345678Z"

      get_response_body = CustomCensusApi.new.send(:get_response_body, document_type, document_number, nil, nil)
      response = CustomCensusApi::Response.new(get_response_body)

      expect(response.valid?).to eq true
      expect(response.date_of_birth).to eq Time.zone.local(1980, 12, 31).to_date
      expect(response.postal_code).to eq "28013"
      expect(response.district_code).to eq "01"
      expect(response.gender).to eq "male"
      expect(response.name).to eq "José García"
    end

  end

end
