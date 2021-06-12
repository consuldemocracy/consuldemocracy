require "rails_helper"

describe CensusCaller do
  let(:api) { CensusCaller.new }

  describe "#call" do
    let(:valid_body) do
      { get_habita_datos_response: {
        get_habita_datos_return: { datos_habitante: { item: { fecha_nacimiento_string: "1-1-1980" }}}
      }}
    end
    let(:invalid_body) do
      { get_habita_datos_response: { get_habita_datos_return: { datos_habitante: {}}}}
    end

    it "returns invalid response when document_number or document_type are empty" do
      response = api.call(1, "", nil, nil)

      expect(response).not_to be_valid

      response = api.call("", "12345678A", nil, nil)

      expect(response).not_to be_valid
    end

    it "returns local census response when census api response is invalid" do
      census_api_response = CensusApi::Response.new(invalid_body)
      allow_any_instance_of(CensusApi).to receive(:call).and_return(census_api_response)
      local_census_response = LocalCensus::Response.new(create(:local_census_record))
      allow_any_instance_of(LocalCensus).to receive(:call).and_return(local_census_response)
      response = api.call(1, "12345678A", nil, nil)

      expect(response).to eq(local_census_response)
    end

    describe "CensusApi" do
      it "returns census api response when it's available and census api response is valid" do
        census_api_response = CensusApi::Response.new(valid_body)
        allow_any_instance_of(CensusApi).to receive(:call).and_return(census_api_response)

        response = api.call(1, "12345678A", nil, nil)

        expect(response).to eq(census_api_response)
      end
    end

    describe "RemoteCensusApi", :remote_census do
      let(:valid_body) { { response: { data: { document_number: "12345678" }}} }
      let(:invalid_body) { { response: { data: {}}} }

      it "returns remote census api response when it's available and response is valid" do
        remote_census_api_response = RemoteCensusApi::Response.new(valid_body)
        allow_any_instance_of(RemoteCensusApi).to receive(:call).and_return(remote_census_api_response)

        response = api.call(1, "12345678A", Date.parse("01/01/1983"), "28001")

        expect(response).to eq(remote_census_api_response)
      end

      it "returns remote census api response when it's available and valid without send
          date_of_birth and postal_code" do
        remote_census_api_response = RemoteCensusApi::Response.new(valid_body)
        allow_any_instance_of(RemoteCensusApi).to receive(:call).and_return(remote_census_api_response)

        response = api.call(1, "12345678A", nil, nil)

        expect(response).to eq(remote_census_api_response)
      end

      it "returns local census record when remote census api it's available but invalid" do
        remote_census_api_response = RemoteCensusApi::Response.new(invalid_body)
        allow_any_instance_of(RemoteCensusApi).to receive(:call).and_return(remote_census_api_response)
        local_census_response = LocalCensus::Response.new(create(:local_census_record))
        allow_any_instance_of(LocalCensus).to receive(:call).and_return(local_census_response)

        response = api.call(1, "12345678A", nil, nil)

        expect(response).to eq(local_census_response)
      end
    end
  end
end
