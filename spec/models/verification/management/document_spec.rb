require "rails_helper"

describe Verification::Management::Document do

  let(:verification_document) { build(:verification_document, document_number: "12345678Z") }

  describe "validations" do

    it "is valid" do
      expect(verification_document).to be_valid
    end

    it "is not valid without a document number" do
      verification_document.document_number = nil
      expect(verification_document).not_to be_valid
    end

    it "is not valid without a document type" do
      verification_document.document_type = nil
      expect(verification_document).not_to be_valid
    end

    it "is valid without a date of birth" do
      verification_document.date_of_birth = nil
      expect(verification_document).to be_valid
    end

    it "is valid without a postal code" do
      verification_document.postal_code = nil
      expect(verification_document).to be_valid
    end

    describe "custom validations with RemoteCensus enabled" do

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
        expect(verification_document).to be_valid
      end

      it "is not valid without a document number" do
        verification_document.document_number = nil
        expect(verification_document).not_to be_valid
      end

      it "is not valid without a document type" do
        verification_document.document_type = nil
        expect(verification_document).not_to be_valid
      end

      it "is not valid without a date of birth" do
        verification_document.date_of_birth = nil

        expect(verification_document).not_to be_valid
      end

      it "is not valid without a postal_code" do
        verification_document.postal_code = nil

        expect(verification_document).not_to be_valid
      end

      describe "dates" do
        it "is valid with a valid date of birth" do
          verification_document = described_class.new("date_of_birth(3i)" => "1",
                                                      "date_of_birth(2i)" => "1",
                                                      "date_of_birth(1i)" => "1980")
          expect(verification_document.errors[:date_of_birth].size).to eq(0)
        end

        it "is not valid without a date of birth" do
          verification_document = described_class.new("date_of_birth(3i)" => "",
                                                      "date_of_birth(2i)" => "",
                                                      "date_of_birth(1i)" => "")
          expect(verification_document).not_to be_valid
          expect(verification_document.errors[:date_of_birth]).to include("can't be blank")
        end
      end

    end

    describe "Allowed Age" do
      let(:min_age)                         { User.minimum_required_age }
      let(:over_minium_age_date_of_birth)   { Date.new((min_age + 10).years.ago.year, 12, 31) }
      let(:under_minium_age_date_of_birth)  { Date.new(min_age.years.ago.year, 12, 31) }
      let(:just_minium_age_date_of_birth)   { Date.new(min_age.years.ago.year, min_age.years.ago.month, min_age.years.ago.day) }

      describe "#valid_age?" do
        it "returns false when the user is younger than the user's minimum required age" do
          census_response = instance_double("CensusApi::Response", date_of_birth: under_minium_age_date_of_birth)
          expect(described_class.new.valid_age?(census_response)).to be false
        end

        it "returns true when the user has the user's minimum required age" do
          census_response = instance_double("CensusApi::Response", date_of_birth: just_minium_age_date_of_birth)
          expect(described_class.new.valid_age?(census_response)).to be true
        end

        it "returns true when the user is older than the user's minimum required age" do
          census_response = instance_double("CensusApi::Response", date_of_birth: over_minium_age_date_of_birth)
          expect(described_class.new.valid_age?(census_response)).to be true
        end
      end

      describe "#under_age?" do
        it "returns true when the user is younger than the user's minimum required age" do
          census_response = instance_double("CensusApi::Response", date_of_birth: under_minium_age_date_of_birth)
          expect(described_class.new.under_age?(census_response)).to be true
        end

        it "returns false when the user is user's minimum required age" do
          census_response = instance_double("CensusApi::Response", date_of_birth: just_minium_age_date_of_birth)
          expect(described_class.new.under_age?(census_response)).to be false
        end

        it "returns false when the user is older than user's minimum required age" do
          census_response = instance_double("CensusApi::Response", date_of_birth: over_minium_age_date_of_birth)
          expect(described_class.new.under_age?(census_response)).to be false
        end
      end
    end
  end

end
