require "rails_helper"

describe LocalCensusRecord do
  let(:local_census_record) { build(:local_census_record) }

  context "validations" do
    it "is valid" do
      expect(local_census_record).to be_valid
    end

    it "is not valid without document_number" do
      local_census_record.document_number = nil

      expect(local_census_record).not_to be_valid
    end

    it "is not valid without document_type" do
      local_census_record.document_type = nil

      expect(local_census_record).not_to be_valid
    end

    it "is not valid when value is not included in allowed document types" do
      local_census_record.document_type = "NIE"

      expect(local_census_record).not_to be_valid
    end

    it "is not valid without date_of_birth" do
      local_census_record.date_of_birth = nil

      expect(local_census_record).not_to be_valid
    end

    it "is not valid without postal_code" do
      local_census_record.postal_code = nil

      expect(local_census_record).not_to be_valid
    end

    it "is not valid when a record already exists with same document_number and document_type" do
      create(:local_census_record, document_number: "#DOC_NUMBER", document_type: "1")
      local_census_record = build(:local_census_record, document_number: "#DOC_NUMBER",
        document_type: "1")

      expect(local_census_record).not_to be_valid
    end

    it "sanitizes text attributes values before validation" do
      local_census_record.document_type = " DNI "
      local_census_record.document_number = " #DOCUMENT_NUMBER "
      local_census_record.postal_code = " 07007 "

      local_census_record.valid?

      expect(local_census_record.document_type).to eq "DNI"
      expect(local_census_record.document_number).to eq "#DOCUMENT_NUMBER"
      expect(local_census_record.postal_code).to eq "07007"
    end
  end

  context "scopes" do
    let!(:a_local_census_record) { create(:local_census_record, document_number: "AAAA") }
    let!(:b_local_census_record) { create(:local_census_record, document_number: "BBBB") }

    context "search" do
      it "filter document_numbers by given terms" do
        expect(LocalCensusRecord.search("A")).to eq [a_local_census_record]
        expect(LocalCensusRecord.search("A")).not_to include b_local_census_record
      end

      it "ignores terms case" do
        expect(LocalCensusRecord.search("a")).to eq [a_local_census_record]
      end
    end
  end
end
