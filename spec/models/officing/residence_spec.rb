require "rails_helper"

describe Officing::Residence do

  let!(:geozone)  { create(:geozone, census_code: "01") }
  let(:residence) { build(:officing_residence, document_number: "12345678Z") }

  describe "validations" do

    it "is valid" do
      expect(residence).to be_valid
    end

    it "is not valid without a document number" do
      residence.document_number = nil
      expect(residence).not_to be_valid
    end

    it "is not valid without a document type" do
      residence.document_type = nil
      expect(residence).not_to be_valid
    end

    it "is not valid without a year of birth" do
      residence.year_of_birth = nil
      expect(residence).not_to be_valid
    end

    it "is valid without a date of birth" do
      residence.date_of_birth = nil
      expect(residence).to be_valid
    end

    it "is valid without a postal code" do
      residence.postal_code = nil
      expect(residence).to be_valid
    end

    describe "custom validations" do

      let(:custom_residence) { build(:officing_residence,
                                     document_number: "12345678Z",
                                     date_of_birth: "01/01/1980",
                                     postal_code: "28001") }

      before do
        Setting["feature.remote_census"] = true
        Setting["remote_census.request.date_of_birth"] = "some.value"
        Setting["remote_census.request.postal_code"] = "some.value"
        access_user_data = "get_habita_datos_response.get_habita_datos_return.datos_habitante.item"
        access_residence_data = "get_habita_datos_response.get_habita_datos_return.datos_vivienda.item"
        Setting["remote_census.response.date_of_birth"] = "#{access_user_data}.fecha_nacimiento_string"
        Setting["remote_census.response.postal_code"] = "#{access_residence_data}.codigo_postal"
        Setting["remote_census.response.valid"] = access_user_data
      end

      after do
        Setting["feature.remote_census"] = nil
        Setting["remote_census.request.date_of_birth"] = nil
        Setting["remote_census.request.postal_code"] = nil
      end

      it "is valid" do
        expect(custom_residence).to be_valid
      end

      it "is not valid without a document number" do
        custom_residence.document_number = nil
        expect(custom_residence).not_to be_valid
      end

      it "is not valid without a document type" do
        custom_residence.document_type = nil
        expect(custom_residence).not_to be_valid
      end

      it "is valid without a year of birth when date_of_birth is present" do
        custom_residence.year_of_birth = nil

        expect(custom_residence).to be_valid
      end

      it "is not valid without a date of birth" do
        custom_residence.date_of_birth = nil

        expect(custom_residence).not_to be_valid
      end

      it "is not valid without a postal_code" do
        custom_residence.postal_code = nil

        expect(custom_residence).not_to be_valid
      end

      describe "dates" do
        it "is valid with a valid date of birth" do
          custom_residence = described_class.new("date_of_birth(3i)" => "1",
                                                 "date_of_birth(2i)" => "1",
                                                 "date_of_birth(1i)" => "1980")
          expect(custom_residence.errors[:date_of_birth].size).to eq(0)
        end

        it "is not valid without a date of birth" do
          custom_residence = described_class.new("date_of_birth(3i)" => "",
                                                 "date_of_birth(2i)" => "",
                                                 "date_of_birth(1i)" => "")
          expect(custom_residence).not_to be_valid
          expect(custom_residence.errors[:date_of_birth]).to include("can't be blank")
        end
      end

      it "stores failed census calls and set postal_code attribute" do
        Setting["remote_census.request.date_of_birth"] = ""

        residence = build(:officing_residence,
                          :invalid,
                          document_number: "12345678Z",
                          postal_code: "00001")
        residence.save

        expect(FailedCensusCall.count).to eq(1)
        expect(FailedCensusCall.first).to have_attributes(
          user_id:         residence.user.id,
          poll_officer_id: residence.officer.id,
          document_number: "12345678Z",
          document_type:   "1",
          date_of_birth: nil,
          postal_code: "00001",
          year_of_birth: Time.current.year
        )
      end

    end

    describe "allowed age" do
      it "is not valid if user is under allowed age" do
        allow_any_instance_of(described_class).to receive(:response_date_of_birth).and_return(15.years.ago)
        expect(residence).not_to be_valid
        expect(residence.errors[:year_of_birth]).to include("You don't have the required age to participate")
      end

      it "is valid if user is above allowed age" do
        allow_any_instance_of(described_class).to receive(:response_date_of_birth).and_return(16.years.ago)
        expect(residence).to be_valid
        expect(residence.errors[:year_of_birth]).to be_empty
      end
    end

  end

  describe "new" do
    it "upcases document number" do
      residence = described_class.new(document_number: "x1234567z")
      expect(residence.document_number).to eq("X1234567Z")
    end

    it "removes all characters except numbers and letters" do
      residence = described_class.new(document_number: " 12.345.678 - B")
      expect(residence.document_number).to eq("12345678B")
    end
  end

  describe "save" do

    it "stores document number, document type, geozone, date of birth and gender" do
      residence.save
      user = residence.user

      expect(user.document_number).to eq("12345678Z")
      expect(user.document_type).to eq("1")
      expect(user.date_of_birth.year).to eq(1980)
      expect(user.date_of_birth.month).to eq(12)
      expect(user.date_of_birth.day).to eq(31)
      expect(user.gender).to eq("male")
      expect(user.geozone).to eq(geozone)
    end

    it "finds existing user and use demographic information" do
      geozone = create(:geozone)
      create(:user, document_number: "12345678Z",
                    document_type: "1",
                    date_of_birth: Date.new(1981, 11, 30),
                    gender: "female",
                    geozone: geozone)

      residence = build(:officing_residence,
                        document_number: "12345678Z",
                        document_type: "1")

      residence.save
      user = residence.user

      expect(user.document_number).to eq("12345678Z")
      expect(user.document_type).to eq("1")
      expect(user.date_of_birth.year).to eq(1981)
      expect(user.date_of_birth.month).to eq(11)
      expect(user.date_of_birth.day).to eq(30)
      expect(user.gender).to eq("female")
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
        date_of_birth: nil,
        postal_code: nil,
        year_of_birth:   Time.current.year
      )
    end

  end
end
