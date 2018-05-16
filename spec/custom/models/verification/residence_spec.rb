require 'rails_helper'

describe Verification::Residence do

  let!(:geozone) { create(:geozone, census_code: "01") }
  let(:residence) { build(:verification_residence, document_number: "12345678Z") }

  describe "validations" do

    describe "dates" do
      it "is valid with a valid date of birth" do
        residence = described_class.new("date_of_birth(3i)" => "1", "date_of_birth(2i)" => "1", "date_of_birth(1i)" => "#{valid_date_of_birth_year}")
        expect(residence.errors[:date_of_birth].size).to eq(0)
      end

    end

  end


  describe "save" do

    it "stores document number, document type, geozone, date of birth and gender" do
      user = create(:user)
      residence.user = user
      residence.save

      user.reload
      expect(user.document_number).to eq('12345678Z')
      expect(user.document_type).to eq("1")
      expect(user.date_of_birth.year).to eq(valid_date_of_birth_year)
      expect(user.date_of_birth.month).to eq(12)
      expect(user.date_of_birth.day).to eq(31)
      expect(user.gender).to eq('male')
      expect(user.geozone).to eq(geozone)
    end

  end

  describe "Failed census call" do
    it "stores failed census API calls" do
      residence = build(:verification_residence, :invalid, document_number: "12345678Z")
      residence.save

      expect(FailedCensusCall.count).to eq(1)
      expect(FailedCensusCall.first).to have_attributes(
        user_id:         residence.user.id,
        document_number: "12345678Z",
        document_type:   "1",
        date_of_birth:   Date.new(valid_date_of_birth_year, 12, 31),
        postal_code:     "28001"
      )
    end
  end

end
