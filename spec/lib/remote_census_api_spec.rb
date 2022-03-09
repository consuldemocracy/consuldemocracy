require "rails_helper"

describe RemoteCensusApi do
  let(:api) { RemoteCensusApi.new }

  describe "#call", :remote_census do
    it "returns a valid response correctly fullfilled when remote response returns a valid response" do
      %w[12345678 12345678z].each { mock_invalid_remote_census_response }
      %w[12345678Z].each { mock_valid_remote_census_response }

      response = api.call("1", "12345678Z", Date.parse("31/12/1980"), "28013")

      expect(response).to be_valid
      expect(response.date_of_birth).to eq Time.zone.local(1980, 12, 31).to_date
      expect(response.postal_code).to eq "28013"
      expect(response.gender).to eq "male"
      expect(response.name).to eq "William Widmore"
    end

    it "returns an invalid response all variants return invalid responses" do
      %w[99999999 99999999z 99999999Z].each { mock_invalid_remote_census_response }

      response = api.call("1", "99999999Z", Date.parse("31/12/1980"), "28013")

      expect(response).not_to be_valid
    end

    describe "request messages" do
      let(:valid_response) { File.read("spec/fixtures/files/remote_census_api/valid.xml") }

      def request_with(params)
        { "request" => params }
      end

      it "includes date_of_birth and postal_code when request structure is configured" do
        params = {
          "document_type" => "1",
          "date_of_birth" => "1980-12-31",
          "postal_code"   => "28013"
        }

        savon.expects(:verify_residence)
             .with(message: request_with(params.merge("document_number" => "12345678")))
             .returns(valid_response)

        api.call("1", "12345678Z", Date.parse("31/12/1980"), "28013")
      end

      it "does not include date_of_birth and postal_code when not configured" do
        Setting["remote_census.request.date_of_birth"] = nil
        Setting["remote_census.request.postal_code"] = nil
        Setting["remote_census.request.structure"] = '{ "request":
          {
            "document_number": "nil",
            "document_type": "null"
          }
        }'

        params = { "document_type" => "1" }

        savon.expects(:verify_residence)
             .with(message: request_with(params.merge("document_number" => "12345678")))
             .returns(valid_response)

        api.call("1", "12345678Z", Date.parse("31/12/1980"), "28013")
      end

      it "includes custom parameters when configured" do
        Setting["remote_census.request.structure"] = '{ "request":
          {
            "document_type": "null",
            "document_number": "nil",
            "date_of_birth": "null",
            "postal_code": "nil",
            "api_key": "your_api_key"
          }
        }'

        params = {
          "document_type" => "1",
          "date_of_birth" => "1980-12-31",
          "postal_code"   => "28013",
          "api_key"       => "your_api_key"
        }

        savon.expects(:verify_residence)
             .with(message: request_with(params.merge("document_number" => "12345678")))
             .returns(valid_response)

        api.call("1", "12345678Z", Date.parse("31/12/1980"), "28013")
      end
    end

    it "returns an invalid response when endpoint is not defined" do
      allow_any_instance_of(RemoteCensusApi).to receive(:end_point_defined?).and_return(false)

      response = api.call("1", "12345678Z", Date.parse("01/01/1983"), "28013")

      expect(response).not_to be_valid
    end
  end
end
