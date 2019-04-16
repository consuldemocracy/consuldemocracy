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
      allow(api).to receive(:get_response_body).with(1, "00123456").and_return(invalid_body)
      allow(api).to receive(:get_response_body).with(1, "123456").and_return(invalid_body)
      allow(api).to receive(:get_response_body).with(1, "0123456").and_return(valid_body)

      response = api.call(1, "123456")

      expect(response).to be_valid
      expect(response.date_of_birth).to eq(Date.new(1980, 1, 1))
    end

    it "returns the last failed response" do
      allow(api).to receive(:get_response_body).with(1, "00123456").and_return(invalid_body)
      allow(api).to receive(:get_response_body).with(1, "123456").and_return(invalid_body)
      allow(api).to receive(:get_response_body).with(1, "0123456").and_return(invalid_body)
      response = api.call(1, "123456")

      expect(response).not_to be_valid
    end
  end

end
