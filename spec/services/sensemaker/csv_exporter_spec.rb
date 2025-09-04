require "rails_helper"

describe Sensemaker::CsvExporter do
  let(:commentable) { create(:debate) }
  let(:csv_exporter) { Sensemaker::CsvExporter.new(commentable) }

  describe "#export_to_csv" do
    it "exports the comments to a CSV file" do
      expect(csv_exporter.export_to_csv).to be_present
    end

    it "exports to the specified file path" do
      file_path = "/tmp/test-export.csv"
      result = csv_exporter.export_to_csv(file_path)
      expect(result).to eq(file_path)
      expect(File.exist?(file_path)).to be true
    end

    it "includes comment data in the CSV" do
      create(:comment, commentable: commentable, body: "Test comment")
      file_path = "/tmp/test-export.csv"

      csv_exporter.export_to_csv(file_path)
      csv_content = File.read(file_path)

      expect(csv_content).to include("Test comment")
      expect(csv_content).to include("comment_id,comment_text,agrees,disagrees,passes")
    end
  end

  describe "#export_to_string" do
    it "exports the comments to a CSV string" do
      create(:comment, commentable: commentable, body: "Test comment")
      result = csv_exporter.export_to_string

      expect(result).to include("Test comment")
      expect(result).to include("comment_id,comment_text,agrees,disagrees,passes")
    end
  end
end
