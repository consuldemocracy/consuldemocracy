require "rails_helper"

describe DirectUpload do
  context "configurations" do
    it "is valid for different kind of combinations when attachment is valid" do
      expect(build(:direct_upload, :proposal, :documents)).to be_valid
      expect(build(:direct_upload, :proposal, :image)).to be_valid
      expect(build(:direct_upload, :budget_investment, :documents)).to be_valid
      expect(build(:direct_upload, :budget_investment, :image)).to be_valid
    end

    it "is not valid for different kind of combinations with invalid atttachment content types" do
      expect(build(:direct_upload, :proposal, :documents, attachment: fixture_file_upload("clippy.png"))).not_to be_valid
      expect(build(:direct_upload, :proposal, :image, attachment: fixture_file_upload("empty.pdf"))).not_to be_valid
      expect(build(:direct_upload, :budget_investment, :documents, attachment: fixture_file_upload("clippy.png"))).not_to be_valid
      expect(build(:direct_upload, :budget_investment, :image, attachment: fixture_file_upload("empty.pdf"))).not_to be_valid
    end

    it "is not valid without resource_type" do
      expect(build(:direct_upload, :proposal, :documents, resource_type: nil)).not_to be_valid
    end

    it "is not valid without resource_relation" do
      expect(build(:direct_upload, :proposal, :documents, resource_relation: nil)).not_to be_valid
    end

    it "is not valid without attachment" do
      expect(build(:direct_upload, :proposal, :documents, attachment: nil)).not_to be_valid
    end

    it "is not valid without user" do
      expect(build(:direct_upload, :proposal, :documents, user: nil)).not_to be_valid
    end
  end

  context "save_attachment" do
    it "saves uploaded file without creating an attachment record" do
      direct_upload = build(:direct_upload, :proposal, :documents)

      direct_upload.save_attachment

      expect(File.exist?(direct_upload.relation.file_path)).to be true
      expect(direct_upload.relation.attachment.blob).to be_persisted
      expect(direct_upload.relation.attachment.attachment).not_to be_persisted
    end
  end
end
