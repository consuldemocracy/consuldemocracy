require "rails_helper"

describe Sensemaker::CsvExporter do
  let(:commentable) { create(:debate) }
  let(:conversation) { Sensemaker::Conversation.new("Debate", commentable.id) }
  let(:csv_exporter) { Sensemaker::CsvExporter.new(conversation) }

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
      expect(csv_content).to include("comment-id,comment_text,agrees,disagrees,passes,author-id")
    end
  end

  describe "#export_to_string" do
    it "exports the comments to a CSV string" do
      create(:comment, commentable: commentable, body: "Test comment")
      result = csv_exporter.export_to_string

      expect(result).to include("Test comment")
      expect(result).to include("comment-id,comment_text,agrees,disagrees,passes,author-id")
    end
  end

  describe ".filter_zero_vote_comments_from_csv" do
    let(:csv_file_path) { "/tmp/test-categorization-output.csv" }
    let(:temp_csv_file) { Tempfile.new(["test-categorization-output", ".csv"]) }

    before do
      temp_csv_file.write("comment-id,comment_text,agrees,disagrees,passes,author-id,topics\n")
      temp_csv_file.write("comment_1,First comment,5,2,1,user_1,Transportation:PublicTransit\n")
      temp_csv_file.write("comment_2,Second comment,0,0,0,user_2,Transportation:Parking\n")
      temp_csv_file.write("comment_3,Third comment,3,0,0,user_3,Technology:Internet\n")
      temp_csv_file.write("comment_4,Fourth comment,0,4,0,user_4,Transportation:Cycling\n")
      temp_csv_file.write("comment_5,Fifth comment,0,0,2,user_5,Technology:Mobile\n")
      temp_csv_file.write("comment_6,Sixth comment,0,0,0,user_6,Transportation:Walking\n")
      temp_csv_file.close

      FileUtils.cp(temp_csv_file.path, csv_file_path)
    end

    after do
      temp_csv_file.unlink
      FileUtils.rm_f(csv_file_path)
      FileUtils.rm_f("#{csv_file_path}.unfiltered")
    end

    it "preserves all columns in the filtered CSV" do
      Sensemaker::CsvExporter.filter_zero_vote_comments_from_csv(csv_file_path)

      filtered_data = CSV.read(csv_file_path, headers: true)
      first_row = filtered_data.first

      expect(first_row.headers).to include("comment-id", "comment_text", "agrees", "disagrees", "passes",
                                           "author-id", "topics")
    end

    it "preserves the topics column from categorization" do
      Sensemaker::CsvExporter.filter_zero_vote_comments_from_csv(csv_file_path)

      filtered_data = CSV.read(csv_file_path, headers: true)
      topics = filtered_data.map { |row| row["topics"] }

      expect(topics).to include("Transportation:PublicTransit", "Technology:Internet",
                                "Transportation:Cycling", "Technology:Mobile")
    end

    it "filters out all zero votes" do
      temp_file = Tempfile.new(["test-pass", ".csv"])
      temp_file.write("comment-id,comment_text,agrees,disagrees,passes,author-id,topics\n")
      temp_file.write("comment_pass,Pass only,0,0,1,user_1,Transportation:PublicTransit\n")
      temp_file.write("comment_disagree,Disagree only,0,2,0,user_1,Transportation:PublicTransit\n")
      temp_file.write("comment_zero,Zero votes,0,0,0,user_2,Transportation:Parking\n")
      temp_file.close
      FileUtils.cp(temp_file.path, csv_file_path)

      comments_count = Sensemaker::CsvExporter.filter_zero_vote_comments_from_csv(csv_file_path)

      filtered_data = CSV.read(csv_file_path, headers: true)
      expect(filtered_data.length).to eq(2)
      expect(filtered_data.first["comment-id"]).to eq("comment_pass")
      expect(comments_count).to eq(2)

      temp_file.unlink
    end

    it "handles empty CSV files gracefully" do
      temp_file = Tempfile.new(["test-pass", ".csv"])
      temp_file.write("comment-id,comment_text,agrees,disagrees,passes,author-id,topics\n")
      temp_file.close
      FileUtils.cp(temp_file.path, csv_file_path)

      expect { Sensemaker::CsvExporter.filter_zero_vote_comments_from_csv(csv_file_path) }.not_to raise_error

      filtered_data = CSV.read(csv_file_path, headers: true)
      expect(filtered_data.length).to eq(0)

      temp_file.unlink
    end

    it "returns early if the CSV file does not exist" do
      non_existent_file = "/tmp/non-existent-file.csv"

      expect(File).to receive(:exist?).with(non_existent_file).and_return(false)
      expect(CSV).not_to receive(:foreach)

      Sensemaker::CsvExporter.filter_zero_vote_comments_from_csv(non_existent_file)
    end

    it "creates an unfiltered backup when filtering is required" do
      Sensemaker::CsvExporter.filter_zero_vote_comments_from_csv(csv_file_path)

      expect(File.exist?("#{csv_file_path}.unfiltered")).to be true

      unfiltered_data = CSV.read("#{csv_file_path}.unfiltered", headers: true)
      expect(unfiltered_data.length).to eq(6)

      filtered_data = CSV.read(csv_file_path, headers: true)
      expect(filtered_data.length).to eq(4)
    end

    it "does not create an unfiltered backup when no filtering is required" do
      temp_file = Tempfile.new(["test-all-votes", ".csv"])
      temp_file.write("comment-id,comment_text,agrees,disagrees,passes,author-id,topics\n")
      temp_file.write("comment_1,First comment,5,2,1,user_1,Transportation:PublicTransit\n")
      temp_file.write("comment_2,Second comment,0,3,0,user_2,Transportation:Parking\n")
      temp_file.write("comment_3,Third comment,3,0,0,user_3,Technology:Internet\n")
      temp_file.close
      FileUtils.cp(temp_file.path, csv_file_path)

      Sensemaker::CsvExporter.filter_zero_vote_comments_from_csv(csv_file_path)

      expect(File.exist?("#{csv_file_path}.unfiltered")).to be false

      temp_file.unlink
    end

    it "handles missing vote columns gracefully" do
      temp_file = Tempfile.new(["test-missing-votes", ".csv"])
      temp_file.write("comment-id,comment_text,author-id,topics\n")
      temp_file.write("comment_1,First comment,user_1,Transportation:PublicTransit\n")
      temp_file.write("comment_2,Second comment,user_2,Transportation:Parking\n")
      temp_file.close
      FileUtils.cp(temp_file.path, csv_file_path)

      expect { Sensemaker::CsvExporter.filter_zero_vote_comments_from_csv(csv_file_path) }.not_to raise_error

      filtered_data = CSV.read(csv_file_path, headers: true)
      expect(filtered_data.length).to eq(0)

      temp_file.unlink
    end
  end
end
