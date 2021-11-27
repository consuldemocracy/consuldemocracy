require "rails_helper"

describe Verification::Residence do
  let!(:geozone) { create(:geozone, census_code: "01") }
  let(:residence) { build(:verification_residence, document_number: "12345678Z") }

  describe "validations" do
    it "is valid" do
      expect(residence).to be_valid
    end

    describe "dates" do
      it "is valid with a valid date of birth" do
        residence = Verification::Residence.new("date_of_birth(3i)" => "1", "date_of_birth(2i)" => "1", "date_of_birth(1i)" => "1980")

        expect(residence.errors[:date_of_birth]).to be_empty
      end

      it "is not valid without a date of birth" do
        residence = Verification::Residence.new("date_of_birth(3i)" => "", "date_of_birth(2i)" => "", "date_of_birth(1i)" => "")
        expect(residence).not_to be_valid
        expect(residence.errors[:date_of_birth]).to include("can't be blank")
      end
    end

    it "validates user has allowed age" do
      residence = Verification::Residence.new("date_of_birth(3i)" => "1",
                                      "date_of_birth(2i)" => "1",
                                      "date_of_birth(1i)" => 5.years.ago.year.to_s)
      expect(residence).not_to be_valid
      expect(residence.errors[:date_of_birth]).to include("You don't have the required age to participate")
    end

    it "validates uniquness of document_number" do
      user = create(:user)
      residence.user = user
      residence.save!

      build(:verification_residence)

      residence.valid?
      expect(residence.errors[:document_number]).to include("has already been taken")
    end

    it "validates census terms" do
      residence.terms_of_service = nil
      expect(residence).not_to be_valid
    end

    describe "postal code" do
      before do
        Setting["postal_codes"] = "28001:28100,28200,28303-455"

        census_data = double(valid?: true, district_code: "", gender: "")
        allow(census_data).to receive(:postal_code) { residence.postal_code }
        allow(census_data).to receive(:date_of_birth) { residence.date_of_birth }
        allow(residence).to receive(:census_data).and_return(census_data)
      end

      it "is not valid when it's nil" do
        residence.postal_code = nil

        expect(residence).not_to be_valid
      end

      it "is valid with postal codes included in settings" do
        residence.postal_code = "28012"
        expect(residence).to be_valid

        residence.postal_code = "28001"
        expect(residence).to be_valid

        residence.postal_code = "28100"
        expect(residence).to be_valid

        residence.postal_code = "28200"
        expect(residence).to be_valid

        residence.postal_code = "28303-455"
        expect(residence).to be_valid
      end

      it "uses string ranges and not integer ranges" do
        Setting["postal_codes"] = "0000-9999"

        residence.postal_code = "02004"

        expect(residence).not_to be_valid
      end

      it "accepts postal codes of any length" do
        Setting["postal_codes"] = "AB1 3NE,815C,38000"

        residence.postal_code = "AB1 3NE"
        expect(residence).to be_valid

        residence.postal_code = "815C"
        expect(residence).to be_valid

        residence.postal_code = "38000"
        expect(residence).to be_valid

        residence.postal_code = "815"
        expect(residence).not_to be_valid
      end

      it "does not ignore spaces inside the postal code" do
        Setting["postal_codes"] = "00001,000 05,00011"

        residence.postal_code = "000 05"
        expect(residence).to be_valid

        residence.postal_code = "00005"
        expect(residence).not_to be_valid
      end

      it "ignores trailing spaces in both the setting and the postal codes" do
        Setting["postal_codes"] = " 00001,00002: 00005, 00011 "

        residence.postal_code = "  00003  "

        expect(residence).to be_valid

        residence.postal_code = "00011   "

        expect(residence).to be_valid
      end

      it "allows regular expressions" do
        Setting["postal_codes"] = "007,[A-Za-z]{2}-[0-9]{3},86"

        residence.postal_code = "007"
        expect(residence).to be_valid

        residence.postal_code = "86"
        expect(residence).to be_valid

        residence.postal_code = "AB-123"
        expect(residence).to be_valid

        residence.postal_code = "zz-789"
        expect(residence).to be_valid

        residence.postal_code = "006"
        expect(residence).not_to be_valid

        residence.postal_code = "87"
        expect(residence).not_to be_valid

        residence.postal_code = "AB-12"
        expect(residence).not_to be_valid

        residence.postal_code = "AB-1234"
        expect(residence).not_to be_valid

        residence.postal_code = "A-123"
        expect(residence).not_to be_valid

        residence.postal_code = "ABC-123"
        expect(residence).not_to be_valid

        residence.postal_code = "ABC-12"
        expect(residence).not_to be_valid

        residence.postal_code = "AB-A12"
        expect(residence).not_to be_valid

        residence.postal_code = "12A-12"
        expect(residence).not_to be_valid

        residence.postal_code = "123-12"
        expect(residence).not_to be_valid

        residence.postal_code = "ABC-A1"
        expect(residence).not_to be_valid

        residence.postal_code = "AB-123\n123"
        expect(residence).not_to be_valid
      end

      it "is not valid with postal codes not included in settings" do
        residence.postal_code = "12345"
        expect(residence).not_to be_valid

        residence.postal_code = "28000"
        expect(residence).not_to be_valid

        residence.postal_code = "28303-454"
        expect(residence).not_to be_valid

        residence.postal_code = "28303"
        expect(residence).not_to be_valid

        residence.postal_code = "28101"
        expect(residence).not_to be_valid
        expect(residence.errors.count).to eq 1
        expect(residence.errors[:postal_code]).to eq ["Citizens from this postal code cannot participate"]
      end

      it "allows any postal code when the setting is blank" do
        Setting["postal_codes"] = nil
        residence.postal_code = "randomthing"

        expect(residence).to be_valid

        Setting["postal_codes"] = ""
        residence.postal_code = "ABC123"

        expect(residence).to be_valid

        Setting["postal_codes"] = "  "
        residence.postal_code = "555-5"

        expect(residence).to be_valid
      end
    end
  end

  describe "new" do
    it "upcases document number" do
      residence = Verification::Residence.new(document_number: "x1234567z")
      expect(residence.document_number).to eq("X1234567Z")
    end

    it "removes all characters except numbers and letters" do
      residence = Verification::Residence.new(document_number: " 12.345.678 - B")
      expect(residence.document_number).to eq("12345678B")
    end
  end

  describe "save" do
    it "stores document number, document type, geozone, date of birth and gender" do
      user = create(:user)
      residence.user = user
      residence.save!

      user.reload
      expect(user.document_number).to eq("12345678Z")
      expect(user.document_type).to eq("1")
      expect(user.date_of_birth.year).to eq(1980)
      expect(user.date_of_birth.month).to eq(12)
      expect(user.date_of_birth.day).to eq(31)
      expect(user.gender).to eq("male")
      expect(user.geozone).to eq(geozone)
    end
  end

  describe "tries" do
    it "increases tries after a call to the Census" do
      residence.postal_code = "28011"
      residence.valid?
      expect(residence.user.lock.tries).to eq(1)
    end

    it "does not increase tries after a validation error" do
      residence.postal_code = ""
      residence.valid?
      expect(residence.user.lock).to be nil
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
        date_of_birth:   Date.new(1980, 12, 31),
        postal_code:     "28001"
      )
    end
  end
end
