require "rails_helper"

describe Sensemaker::CsvExporter do
  let(:commentable) { create(:debate) }
  let(:csv_exporter) { Sensemaker::CsvExporter.new(commentable) }

  describe "#export_to_csv" do
    it "exports the comments to a CSV file" do
      expect(csv_exporter.export_to_csv).to be_present
    end
  end

  describe "#export_to_string" do
    it "exports the comments to a CSV file" do
      expect(csv_exporter.export_to_string).to be_present
    end
  end
end
