require 'rails_helper'

describe Officing::Residence do

  let!(:geozone)  { create(:geozone, census_code: "01") }
  let(:residence) { build(:officing_residence, document_number: "12345678Z") }

  describe "validations" do

    it "should be valid" do
      expect(residence).to be_valid
    end

    it "should not be valid without a document number" do
      residence.document_number = nil
      expect(residence).to_not be_valid
    end

    it "should not be valid without a document type" do
      residence.document_type = nil
      expect(residence).to_not be_valid
    end

    it "should not be valid without a year of birth" do
      residence.year_of_birth = nil
      expect(residence).to_not be_valid
    end

    describe "allowed age" do
      it "should not be valid if user is under allowed age" do
        allow_any_instance_of(Officing::Residence).to receive(:date_of_birth).and_return(15.years.ago)
        expect(residence).to_not be_valid
        expect(residence.errors[:year_of_birth]).to include("You don't have the required age to participate")
      end

      it "should be valid if user is above allowed age" do
        allow_any_instance_of(Officing::Residence).to receive(:date_of_birth).and_return(16.years.ago)
        expect(residence).to be_valid
        expect(residence.errors[:year_of_birth]).to be_empty
      end
    end

  end

  describe "new" do
    it "should upcase document number" do
      residence = Officing::Residence.new(document_number: "x1234567z")
      expect(residence.document_number).to eq("X1234567Z")
    end

    it "should remove all characters except numbers and letters" do
      residence = Officing::Residence.new(document_number: " 12.345.678 - B")
      expect(residence.document_number).to eq("12345678B")
    end
  end

  describe "save" do

    it "should store document number, document type, geozone, date of birth and gender" do
      residence.save
      user = residence.user

      expect(user.document_number).to eq('12345678Z')
      expect(user.document_type).to eq("1")
      expect(user.date_of_birth.year).to eq(1980)
      expect(user.date_of_birth.month).to eq(12)
      expect(user.date_of_birth.day).to eq(31)
      expect(user.gender).to eq('male')
      expect(user.geozone).to eq(geozone)
    end

    it "should find existing user and use demographic information" do
      geozone = create(:geozone)
      create(:user, document_number: "12345678Z",
                    document_type: "1",
                    date_of_birth: Date.new(1981, 11, 30),
                    gender: 'female',
                    geozone: geozone)

      residence = build(:officing_residence,
                        document_number: "12345678Z",
                        document_type: "1")

      residence.save
      user = residence.user

      expect(user.document_number).to eq('12345678Z')
      expect(user.document_type).to eq("1")
      expect(user.date_of_birth.year).to eq(1981)
      expect(user.date_of_birth.month).to eq(11)
      expect(user.date_of_birth.day).to eq(30)
      expect(user.gender).to eq('female')
      expect(user.geozone).to eq(geozone)
    end

    it "makes half-verified users fully verified" do
      user = create(:user, residence_verified_at: Time.current, document_type: "1", document_number: "12345678Z")
      expect(user).to be_unverified
      residence = build(:officing_residence, document_number: "12345678Z", year_of_birth: 1980)
      expect(residence).to be_valid
      expect(user.reload).to be_unverified
      residence.save
      expect(user.reload).to be_level_three_verified
    end

    it "stores failed census calls" do
      residence = build(:officing_residence, :invalid, document_number: "12345678Z")
      residence.save

      expect(FailedCensusCall.count).to eq(1)
      expect(FailedCensusCall.first).to have_attributes(
        user_id:         residence.user.id,
        poll_officer_id: residence.officer.id,
        document_number: "12345678Z",
        document_type:   "1",
        year_of_birth:   Time.current.year
      )
    end

  end
end
