require 'rails_helper'

describe Officing::Residence do

  let!(:geozone)  { create(:geozone, census_code: "01") }
  let(:residence) { build(:officing_residence, document_number: "12345678Z") }

  describe "validations" do

    it "should be valid" do
      expect(residence).to be_valid
    end

    describe "dates" do
      it "should be valid with a valid date of birth" do
        residence = Officing::Residence.new({"date_of_birth(3i)"=>"1", "date_of_birth(2i)"=>"1", "date_of_birth(1i)"=>"1980"})
        expect(residence.errors[:date_of_birth].size).to eq(0)
      end

      it "should not be valid without a date of birth" do
        residence = Officing::Residence.new({"date_of_birth(3i)"=>"", "date_of_birth(2i)"=>"", "date_of_birth(1i)"=>""})
        expect(residence).to_not be_valid
        expect(residence.errors[:date_of_birth]).to include("can't be blank")
      end
    end

    it "should validate user has allowed age" do
      residence = Officing::Residence.new({"date_of_birth(3i)"=>"1", "date_of_birth(2i)"=>"1", "date_of_birth(1i)"=>"#{5.year.ago.year}"})
      expect(residence).to_not be_valid
      expect(residence.errors[:date_of_birth]).to include("You don't have the required age to participate")
    end

  end

  describe "new" do
    it "should upcase document number" do
      residence = Officing::Residence.new({document_number: "x1234567z"})
      expect(residence.document_number).to eq("X1234567Z")
    end

    it "should remove all characters except numbers and letters" do
      residence = Officing::Residence.new({document_number: " 12.345.678 - B"})
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

  end
end