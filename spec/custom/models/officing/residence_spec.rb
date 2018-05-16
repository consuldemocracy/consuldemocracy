require 'rails_helper'

describe Officing::Residence do

  let!(:geozone)  { create(:geozone, census_code: "01") }
  let(:residence) { build(:officing_residence, document_number: "12345678Z") }

  describe "save" do

    it "stores document number, document type, geozone, date of birth and gender" do
      residence.save
      user = residence.user

      expect(user.document_number).to eq('12345678Z')
      expect(user.document_type).to eq("1")
      expect(user.date_of_birth.year).to eq(valid_date_of_birth_year)
      expect(user.date_of_birth.month).to eq(12)
      expect(user.date_of_birth.day).to eq(31)
      expect(user.gender).to eq('male')
      expect(user.geozone).to eq(geozone)
    end

    it "finds existing user and use demographic information" do
      geozone = create(:geozone)
      create(:user, document_number: "12345678Z",
                    document_type: "1",
                    date_of_birth: Date.new(valid_date_of_birth_year+1, 11, 30),
                    gender: 'female',
                    geozone: geozone)

      residence = build(:officing_residence,
                        document_number: "12345678Z",
                        document_type: "1")

      residence.save
      user = residence.user

      expect(user.document_number).to eq('12345678Z')
      expect(user.document_type).to eq("1")
      expect(user.date_of_birth.year).to eq(valid_date_of_birth_year+1)
      expect(user.date_of_birth.month).to eq(11)
      expect(user.date_of_birth.day).to eq(30)
      expect(user.gender).to eq('female')
      expect(user.geozone).to eq(geozone)
    end

    it "makes half-verified users fully verified" do
      user = create(:user, residence_verified_at: Time.current, document_type: "1", document_number: "12345678Z")
      expect(user).to be_unverified
      residence = build(:officing_residence, document_number: "12345678Z", year_of_birth: valid_date_of_birth_year)
      expect(residence).to be_valid
      expect(user.reload).to be_unverified
      residence.save
      expect(user.reload).to be_level_three_verified
    end

  end
end
