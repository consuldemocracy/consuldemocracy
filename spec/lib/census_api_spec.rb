require 'rails_helper'

describe CensusApi do
  let(:api) { described_class.new }

  describe '#get_tried_numbers' do
    it "trims and cleans up entry" do
      expect(api.get_tried_numbers(2, '  1 2@ 34')).to eq(['1234'])
    end

    it "returns only one try for passports & residence cards" do
      expect(api.get_tried_numbers(2, '1234')).to eq(['1234'])
      expect(api.get_tried_numbers(3, '1234')).to eq(['1234'])
    end

    it 'takes only the last 8 digits for dnis and resicence cards' do
      expect(api.get_tried_numbers(1, '543212345678')).to eq(['12345678'])
    end

    it 'tries all the dni variations padding with zeroes' do
      expect(api.get_tried_numbers(1, '0123456')).to eq(['123456', '0123456', '00123456'])
      expect(api.get_tried_numbers(1, '00123456')).to eq(['123456', '0123456', '00123456'])
    end

    it 'adds upper and lowercase letter when the letter is present' do
      expect(api.get_tried_numbers(1, '1234567A')).to eq(['1234567', '01234567', '1234567a', '1234567A', '01234567a', '01234567A'])
    end
  end

end
