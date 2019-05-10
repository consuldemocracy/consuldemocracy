require "rails_helper"

describe CensusApi do
  let(:api) { described_class.new }

  describe "#get_document_number_variants" do
    it "trims and cleans up entry" do
      expect(api.get_document_number_variants(2, "  1 2@ 34")).to eq(["1234"])
    end

    it "returns only one try for passports & residence cards" do
      expect(api.get_document_number_variants(2, "1234")).to eq(["1234"])
      expect(api.get_document_number_variants(3, "1234")).to eq(["1234"])
    end

    it "takes only the last 8 digits for dnis and resicence cards" do
      expect(api.get_document_number_variants(1, "543212345678")).to eq(["12345678"])
    end

    it "tries all the dni variants padding with zeroes" do
      expect(api.get_document_number_variants(1, "0123456")).to eq(["123456", "0123456", "00123456"])
      expect(api.get_document_number_variants(1, "00123456")).to eq(["123456", "0123456", "00123456"])
    end

    it "adds upper and lowercase letter when the letter is present" do
      expect(api.get_document_number_variants(1, "1234567A")).to eq(%w(1234567 01234567 1234567a 1234567A 01234567a 01234567A))
    end
  end

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
