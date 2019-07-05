require "rails_helper"

describe RemoteCensusApi do
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

    before do
      access_user_data = "get_habita_datos_response.get_habita_datos_return.datos_habitante.item"
      access_residence_data = "get_habita_datos_response.get_habita_datos_return.datos_vivienda.item"
      Setting["remote_census.response.date_of_birth"] = "#{access_user_data}.fecha_nacimiento_string"
      Setting["remote_census.response.postal_code"] = "#{access_residence_data}.codigo_postal"
      Setting["remote_census.response.valid"] = access_user_data
    end

    it "returns the response for the first valid variant" do
      date = Date.parse("01/01/1983")
      allow(api).to receive(:get_response_body).with(1, "00123456", date, "28001").and_return(invalid_body)
      allow(api).to receive(:get_response_body).with(1, "123456", date, "28001").and_return(invalid_body)
      allow(api).to receive(:get_response_body).with(1, "0123456", date, "28001").and_return(valid_body)

      response = api.call(1, "123456", date, "28001")

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
      date = Date.parse("01/01/1983")
      allow(api).to receive(:get_response_body).with(1, "00123456", date, "28001").and_return(invalid_body)
      allow(api).to receive(:get_response_body).with(1, "123456", date, "28001").and_return(invalid_body)
      allow(api).to receive(:get_response_body).with(1, "0123456", date, "28001").and_return(invalid_body)
      response = api.call(1, "123456", date, "28001")

      expect(response).not_to be_valid
    end
  end

  describe "request structure correctly filled" do

    before do
      Setting["feature.remote_census"] = true
      Setting["remote_census.request.structure"] = "{ request:
                                                      { codigo_institucion: 1,
                                                        codigo_portal: 1,
                                                        codigo_usuario: 1,
                                                        documento: 'xxx',
                                                        tipo_documento: 'xxx',
                                                        codigo_idioma: '102',
                                                        nivel: '3' }
                                                    }"
      Setting["remote_census.request.document_type"] = "request.tipo_documento"
      Setting["remote_census.request.document_number"] = "request.documento"
      Setting["remote_census.request.date_of_birth"] = nil
      Setting["remote_census.request.postal_code"] = nil
    end

    it "with default values" do
      document_type = "1"
      document_number = "0123456"

      request = RemoteCensusApi.new.send(:request, document_type, document_number, nil, nil)

      expect(request).to eq ({:request=>
                              {:codigo_institucion=>1,
                               :codigo_portal=>1,
                               :codigo_usuario=>1,
                               :documento=>"0123456",
                               :tipo_documento=>"1",
                               :codigo_idioma=>"102",
                               :nivel=>"3"}
                              })
    end

    it "when send date_of_birth and postal_code but are not configured" do
      document_type = "1"
      document_number = "0123456"
      date_of_birth =  Date.new(1980, 1, 1)
      postal_code = "28001"

      request = RemoteCensusApi.new.send(:request, document_type, document_number, date_of_birth, postal_code)

      expect(request).to eq ({:request=>
                              {:codigo_institucion=>1,
                               :codigo_portal=>1,
                               :codigo_usuario=>1,
                               :documento=>"0123456",
                               :tipo_documento=>"1",
                               :codigo_idioma=>"102",
                               :nivel=>"3"}
                              })
    end

    it "when send date_of_birth and postal_code but are configured" do
      Setting["remote_census.request.structure"] = "{ request:
                                                      { codigo_institucion: 1,
                                                        codigo_portal: 1,
                                                        codigo_usuario: 1,
                                                        documento: nil,
                                                        tipo_documento: nil,
                                                        fecha_nacimiento: nil,
                                                        codigo_postal: nil,
                                                        codigo_idioma: '102',
                                                        nivel: '3' }
                                                    }"
      Setting["remote_census.request.date_of_birth"] = "request.fecha_nacimiento"
      Setting["remote_census.request.postal_code"] = "request.codigo_postal"
      document_type = "1"
      document_number = "0123456"
      date_of_birth =  Date.new(1980, 1, 1)
      postal_code = "28001"

      request = RemoteCensusApi.new.send(:request, document_type, document_number, date_of_birth, postal_code)

      expect(request).to eq ({:request=>
                              {:codigo_institucion=>1,
                               :codigo_portal=>1,
                               :codigo_usuario=>1,
                               :documento=>"0123456",
                               :tipo_documento=>"1",
                               :fecha_nacimiento=>"1980-01-01",
                               :codigo_postal=>"28001",
                               :codigo_idioma=>"102",
                               :nivel=>"3"}
                              })
    end

  end

  describe "get_response_body" do

    before do
      Setting["feature.remote_census"] = true
    end

    it "return expected stubbed_response" do
      document_type = "1"
      document_number = "12345678Z"

      response = RemoteCensusApi.new.send(:get_response_body, document_type, document_number, nil, nil)

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

  describe "RemoteCensusApi::Response" do

    before do
      Setting["feature.remote_census"] = true
      access_user_data = "get_habita_datos_response.get_habita_datos_return.datos_habitante.item"
      access_residence_data = "get_habita_datos_response.get_habita_datos_return.datos_vivienda.item"
      Setting["remote_census.response.date_of_birth"] = "#{access_user_data}.fecha_nacimiento_string"
      Setting["remote_census.response.postal_code"] = "#{access_residence_data}.codigo_postal"
      Setting["remote_census.response.district"] = "#{access_residence_data}.codigo_distrito"
      Setting["remote_census.response.gender"] = "#{access_user_data}.descripcion_sexo"
      Setting["remote_census.response.name"] = "#{access_user_data}.nombre"
      Setting["remote_census.response.surname"] = "#{access_user_data}.apellido1"
      Setting["remote_census.response.valid"] = access_user_data
    end

    it "return expected response methods with default values" do
      document_type = "1"
      document_number = "12345678Z"

      get_response_body = RemoteCensusApi.new.send(:get_response_body, document_type, document_number, nil, nil)
      response = RemoteCensusApi::Response.new(get_response_body)

      expect(response.valid?).to eq true
      expect(response.date_of_birth).to eq Time.zone.local(1980, 12, 31).to_date
      expect(response.postal_code).to eq "28013"
      expect(response.district_code).to eq "01"
      expect(response.gender).to eq "male"
      expect(response.name).to eq "José García"
    end

  end

end
