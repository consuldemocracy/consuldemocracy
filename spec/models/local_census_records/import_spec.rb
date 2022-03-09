require "rails_helper"

describe LocalCensusRecords::Import do
  let(:base_files_path) { %w[spec fixtures files local_census_records import] }
  let(:import) { build(:local_census_records_import) }

  describe "Validations" do
    it "is valid" do
      expect(import).to be_valid
    end

    it "is not valid without a file to import" do
      import.file = nil

      expect(import).not_to be_valid
    end

    context "When file extension" do
      it "is wrong it should not be valid" do
        file = Rack::Test::UploadedFile.new("spec/fixtures/files/clippy.gif")
        import = build(:local_census_records_import, file: file)

        expect(import).not_to be_valid
      end

      it "is csv it should be valid" do
        path = base_files_path << "valid.csv"
        file = Rack::Test::UploadedFile.new(Rails.root.join(*path))
        import = build(:local_census_records_import, file: file)

        expect(import).to be_valid
      end
    end

    context "When file headers" do
      it "are all missing it should not be valid" do
        path = base_files_path << "valid-without-headers.csv"
        file = Rack::Test::UploadedFile.new(Rails.root.join(*path))
        import = build(:local_census_records_import, file: file)

        expect(import).not_to be_valid
      end
    end
  end

  describe "#save" do
    it "Create valid local census records with provided values" do
      import.save!
      local_census_record = LocalCensusRecord.find_by(document_number: "X11556678")

      expect(local_census_record).not_to be_nil
      expect(local_census_record.document_type).to eq("2")
      expect(local_census_record.document_number).to eq("X11556678")
      expect(local_census_record.date_of_birth).to eq(Date.parse("07/08/1987"))
      expect(local_census_record.postal_code).to eq("7008")
    end

    it "Add successfully created local census records to created_records array" do
      import.save!

      valid_document_numbers = ["44556678T", "33556678T", "22556678T", "X11556678"]
      expect(import.created_records.map(&:document_number)).to eq(valid_document_numbers)
    end

    it "Add invalid local census records to invalid_records array" do
      path = base_files_path << "invalid.csv"
      file = Rack::Test::UploadedFile.new(Rails.root.join(*path))
      import.file = file

      import.save!

      invalid_records_document_types = [nil, "1", "2", "3", "DNI"]
      invalid_records_document_numbers = ["44556678T", nil, "22556678T", "X11556678", "Z11556678"]
      invalid_records_date_of_births = [Date.parse("07/08/1984"), Date.parse("07/08/1985"), nil,
        Date.parse("07/08/1987"), Date.parse("07/08/1987")]
      invalid_records_postal_codes = ["7008", "7009", "7010", nil, "7011"]
      expect(import.invalid_records.map(&:document_type))
        .to eq(invalid_records_document_types)
      expect(import.invalid_records.map(&:document_number))
        .to eq(invalid_records_document_numbers)
      expect(import.invalid_records.map(&:date_of_birth))
        .to eq(invalid_records_date_of_births)
      expect(import.invalid_records.map(&:postal_code))
      .to eq(invalid_records_postal_codes)
    end
  end
end
