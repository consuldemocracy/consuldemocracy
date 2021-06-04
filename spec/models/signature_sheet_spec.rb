require "rails_helper"

describe SignatureSheet do
  let(:signature_sheet) { build(:signature_sheet) }

  describe "validations" do
    it "is valid" do
      expect(signature_sheet).to be_valid
    end

    it "is valid with a valid signable" do
      signature_sheet.signable = create(:proposal)
      expect(signature_sheet).to be_valid

      signature_sheet.signable = create(:budget_investment)
      expect(signature_sheet).to be_valid
    end

    it "is not valid without signable" do
      signature_sheet.signable = nil
      expect(signature_sheet).not_to be_valid
    end

    it "is not valid without a valid signable" do
      signature_sheet.signable = create(:comment)
      expect(signature_sheet).not_to be_valid
    end

    it "is not valid without document numbers" do
      signature_sheet.required_fields_to_verify = nil
      expect(signature_sheet).not_to be_valid
    end

    it "is not valid without an author" do
      signature_sheet.author = nil
      expect(signature_sheet).not_to be_valid
    end
  end

  describe "#name" do
    context "when title is nil" do
      it "returns name for proposal signature sheets" do
        proposal = create(:proposal)
        signature_sheet.signable = proposal

        expect(signature_sheet.name).to eq("Citizen proposal #{proposal.id}")
      end

      it "returns name for budget investment signature sheets" do
        budget_investment = create(:budget_investment)
        signature_sheet.signable = budget_investment

        expect(signature_sheet.name).to eq("Investment #{budget_investment.id}")
      end
    end

    context "when title is not nil" do
      let(:signature_sheet) { build(:signature_sheet, :with_title) }

      it "returns name for proposal signature sheets" do
        proposal = create(:proposal)
        signature_sheet.signable = proposal

        expect(signature_sheet.name).to eq("Citizen proposal #{proposal.id}: #{signature_sheet.title}")
      end

      it "returns name for budget investment signature sheets" do
        budget_investment = create(:budget_investment)
        signature_sheet.signable = budget_investment

        expect(signature_sheet.name).to eq("Investment #{budget_investment.id}: #{signature_sheet.title}")
      end
    end

    context "when title is an empty string" do
      let(:signature_sheet) { build(:signature_sheet, title: "") }

      it "returns name for proposal signature sheets" do
        proposal = create(:proposal)
        signature_sheet.signable = proposal

        expect(signature_sheet.name).to eq("Citizen proposal #{proposal.id}")
      end

      it "returns name for budget investment signature sheets" do
        budget_investment = create(:budget_investment)
        signature_sheet.signable = budget_investment

        expect(signature_sheet.name).to eq("Investment #{budget_investment.id}")
      end
    end
  end

  describe "#verify_signatures" do
    it "creates signatures for each document number" do
      signature_sheet = create(:signature_sheet, required_fields_to_verify: "123A; 456B")
      signature_sheet.verify_signatures

      expect(Signature.count).to eq(2)
      expect(Signature.first.document_number).to eq("123A")
      expect(Signature.first.date_of_birth).to eq(nil)
      expect(Signature.first.postal_code).to eq(nil)
      expect(Signature.last.document_number).to eq("456B")
      expect(Signature.last.date_of_birth).to eq(nil)
      expect(Signature.last.postal_code).to eq(nil)
    end

    it "marks signature sheet as processed" do
      signature_sheet = create(:signature_sheet)
      signature_sheet.verify_signatures

      expect(signature_sheet.processed).to eq(true)
    end

    context "with remote census active", :remote_census do
      it "creates signatures for each group with document_number" do
        Setting["remote_census.request.date_of_birth"] = nil
        Setting["remote_census.request.postal_code"] = nil

        required_fields_to_verify = "123A; 456B"
        signature_sheet = create(:signature_sheet, required_fields_to_verify: required_fields_to_verify)

        %w[123A 456B].each { mock_valid_remote_census_response }
        signature_sheet.verify_signatures

        expect(Signature.count).to eq(2)
        expect(Signature.first.document_number).to eq("123A")
        expect(Signature.first.date_of_birth).to eq(nil)
        expect(Signature.first.postal_code).to eq(nil)
        expect(Signature.last.document_number).to eq("456B")
        expect(Signature.last.date_of_birth).to eq(nil)
        expect(Signature.last.postal_code).to eq(nil)
      end

      it "creates signatures for each group with document_number and date_of_birth" do
        Setting["remote_census.request.postal_code"] = nil

        required_fields_to_verify = "123A, 01/01/1980; 456B, 01/02/1980"
        signature_sheet = create(:signature_sheet, required_fields_to_verify: required_fields_to_verify)

        %w[123A 456B].each { mock_valid_remote_census_response }
        signature_sheet.verify_signatures

        expect(Signature.count).to eq(2)
        expect(Signature.first.document_number).to eq("123A")
        expect(Signature.first.date_of_birth).to eq(Date.parse("01/01/1980"))
        expect(Signature.first.postal_code).to eq(nil)
        expect(Signature.last.document_number).to eq("456B")
        expect(Signature.last.date_of_birth).to eq(Date.parse("01/02/1980"))
        expect(Signature.last.postal_code).to eq(nil)
      end

      it "creates signatures for each group with document_number and postal_code" do
        Setting["remote_census.request.date_of_birth"] = nil

        required_fields_to_verify = "123A, 28001; 456B, 28002"
        signature_sheet = create(:signature_sheet, required_fields_to_verify: required_fields_to_verify)

        %w[123A 456B].each { mock_valid_remote_census_response }
        signature_sheet.verify_signatures

        expect(Signature.count).to eq(2)
        expect(Signature.first.document_number).to eq("123A")
        expect(Signature.first.date_of_birth).to eq(nil)
        expect(Signature.first.postal_code).to eq("28001")
        expect(Signature.last.document_number).to eq("456B")
        expect(Signature.last.date_of_birth).to eq(nil)
        expect(Signature.last.postal_code).to eq("28002")
      end

      it "creates signatures for each group with document_number, postal_code and date_of_birth" do
        required_fields_to_verify = "123A, 01/01/1980, 28001; 456B, 01/02/1980, 28002"
        signature_sheet = create(:signature_sheet, required_fields_to_verify: required_fields_to_verify)

        %w[123A 456B].each { mock_valid_remote_census_response }
        signature_sheet.verify_signatures

        expect(Signature.count).to eq(2)
        expect(Signature.first.document_number).to eq("123A")
        expect(Signature.first.date_of_birth).to eq(Date.parse("01/01/1980"))
        expect(Signature.first.postal_code).to eq("28001")
        expect(Signature.last.document_number).to eq("456B")
        expect(Signature.last.date_of_birth).to eq(Date.parse("01/02/1980"))
        expect(Signature.last.postal_code).to eq("28002")
      end
    end
  end

  describe "#parsed_required_fields_to_verify" do
    it "returns an array after spliting document numbers by semicolons" do
      signature_sheet.required_fields_to_verify = "123A\r\n;456B;\n789C;123B"

      expect(signature_sheet.parsed_required_fields_to_verify_groups).to eq([["123A"], ["456B"], ["789C"], ["123B"]])
    end

    it "returns an array after spliting all required_fields_to_verify by semicolons" do
      required_fields_to_verify = "123A\r\n, 01/01/1980\r\n, 28001\r\n; 456B\n, 01/02/1980\n, 28002\n; 789C, 01/03/1980"
      # signature_sheet.required_fields_to_verify = "123A\r\n456B\n789C;123B"
      signature_sheet.required_fields_to_verify = required_fields_to_verify

      expect(signature_sheet.parsed_required_fields_to_verify_groups).to eq([["123A", "01/01/1980", "28001"], ["456B", "01/02/1980", "28002"], ["789C", "01/03/1980"]])
    end

    it "strips spaces between number and letter" do
      signature_sheet.required_fields_to_verify = "123 A, 01/01/1980, 28001;\n456 B , 01/02/1980, 28002;\n 789C ,01/03/1980, 28 003"

      expect(signature_sheet.parsed_required_fields_to_verify_groups).to eq([["123A", "01/01/1980", "28001"], ["456B", "01/02/1980", "28002"], ["789C", "01/03/1980", "28003"]])
    end
  end
end
