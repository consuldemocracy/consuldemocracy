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

    describe "custom validations with RemoteCensus enabled", :remote_census do
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
          verification_document = Verification::Management::Document.new(date_of_birth: "1980-01-01")

          expect(verification_document.errors[:date_of_birth]).to be_empty
        end

        it "is not valid without a date of birth" do
          verification_document = Verification::Management::Document.new(date_of_birth: "")
          expect(verification_document).not_to be_valid
          expect(verification_document.errors[:date_of_birth]).to include("can't be blank")
        end
      end
    end

    describe "Allowed Age" do
      let(:min_age)                         { User.minimum_required_age }
      let(:over_minimum_age_date_of_birth)  { Date.new((min_age + 10).years.ago.year, 12, 31) }
      let(:under_minimum_age_date_of_birth) { Date.new(min_age.years.ago.year, 12, 31) }
      let(:just_minimum_age_date_of_birth) do
        Date.new(min_age.years.ago.year, min_age.years.ago.month, min_age.years.ago.day)
      end

      describe "#valid_age?" do
        it "returns false when the user is younger than the user's minimum required age" do
          census_response = double(date_of_birth: under_minimum_age_date_of_birth)
          expect(Verification::Management::Document.new.valid_age?(census_response)).to be false
        end

        it "returns true when the user has the user's minimum required age" do
          census_response = double(date_of_birth: just_minimum_age_date_of_birth)
          expect(Verification::Management::Document.new.valid_age?(census_response)).to be true
        end

        it "returns true when the user is older than the user's minimum required age" do
          census_response = double(date_of_birth: over_minimum_age_date_of_birth)
          expect(Verification::Management::Document.new.valid_age?(census_response)).to be true
        end
      end

      describe "#under_age?" do
        it "returns true when the user is younger than the user's minimum required age" do
          census_response = double(date_of_birth: under_minimum_age_date_of_birth)
          expect(Verification::Management::Document.new.under_age?(census_response)).to be true
        end

        it "returns false when the user is user's minimum required age" do
          census_response = double(date_of_birth: just_minimum_age_date_of_birth)
          expect(Verification::Management::Document.new.under_age?(census_response)).to be false
        end

        it "returns false when the user is older than user's minimum required age" do
          census_response = double(date_of_birth: over_minimum_age_date_of_birth)
          expect(Verification::Management::Document.new.under_age?(census_response)).to be false
        end
      end
    end
  end

  describe "document_number and document_type normalization" do
    it "upcases document number" do
      document = Verification::Management::Document.new(document_number: "x1234567z")
      expect(document.document_number).to eq("X1234567Z")
    end

    it "removes all characters except numbers and letters" do
      document = Verification::Management::Document.new(document_number: " 12.345.678 - B")
      expect(document.document_number).to eq("12345678B")
    end

    it "strips leading and trailing whitespace from the document type" do
      verification = Verification::Management::Document.new(document_type: " 1 ")
      expect(verification.document_type).to eq "1"
    end

    it "passes the normalized document type and number to the census caller" do
      verification = Verification::Management::Document.new(document_type: " 1 ")
      census_caller = instance_double(CensusCaller)
      allow(CensusCaller).to receive(:new).and_return(census_caller)

      expect(census_caller).to receive(:call).with("1", any_args).and_return(double(valid?: false))
      verification.in_census?
    end
  end
end
