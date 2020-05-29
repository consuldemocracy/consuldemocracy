require "rails_helper"

describe LocalCensus do
  let(:api) { LocalCensus.new }

  describe "#call" do
    let(:invalid_body) { nil }
    let(:valid_body) { create(:local_census_record) }

    it "returns the response for the first valid variant" do
      allow(api).to receive(:get_record).with(1, "00123456").and_return(invalid_body)
      allow(api).to receive(:get_record).with(1, "123456").and_return(invalid_body)
      allow(api).to receive(:get_record).with(1, "0123456").and_return(valid_body)

      response = api.call(1, "123456")

      expect(response).to be_valid
      expect(response.date_of_birth).to eq(Date.new(1970, 1, 31))
    end

    it "returns the last failed response" do
      allow(api).to receive(:get_record).with(1, "00123456").and_return(invalid_body)
      allow(api).to receive(:get_record).with(1, "123456").and_return(invalid_body)
      allow(api).to receive(:get_record).with(1, "0123456").and_return(invalid_body)
      response = api.call(1, "123456")

      expect(response).not_to be_valid
    end
  end
end
