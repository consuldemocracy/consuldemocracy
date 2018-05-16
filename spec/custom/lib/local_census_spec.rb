require 'rails_helper'

describe LocalCensus do
  let(:api) { described_class.new }

  describe '#call' do
    let(:invalid_body) { nil }
    let(:valid_body) { create(:local_census_record) }

    it "returns the response for the first valid variant" do
      allow(api).to receive(:get_record).with(1, "00123456").and_return(invalid_body)
      allow(api).to receive(:get_record).with(1, "123456").and_return(invalid_body)
      allow(api).to receive(:get_record).with(1, "0123456").and_return(valid_body)

      response = api.call(1, "123456")

      expect(response).to be_valid
      expect(response.date_of_birth).to eq(Date.new(valid_date_of_birth_year, 1, 31))
    end
  end

end
