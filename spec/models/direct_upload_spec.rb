require 'rails_helper'

describe DirectUpload do

  context "configurations" do

    it "should be valid for different kind of combinations when attachment is valid" do
      expect(build(:direct_upload, :proposal, :documents)).to be_valid
      expect(build(:direct_upload, :proposal, :image)).to be_valid
      expect(build(:direct_upload, :budget_investment, :documents)).to be_valid
      expect(build(:direct_upload, :budget_investment, :image)).to be_valid
    end

    it "should not be valid for different kind of combinations with invalid atttachment content types" do
      expect(build(:direct_upload, :proposal, :documents, attachment: File.new("spec/fixtures/files/clippy.png"))).not_to be_valid
      expect(build(:direct_upload, :proposal, :image, attachment: File.new("spec/fixtures/files/empty.pdf"))).not_to be_valid
      expect(build(:direct_upload, :budget_investment, :documents, attachment: File.new("spec/fixtures/files/clippy.png"))).not_to be_valid
      expect(build(:direct_upload, :budget_investment, :image, attachment: File.new("spec/fixtures/files/empty.pdf"))).not_to be_valid
    end

    it "should not be valid without resource_type" do
      expect(build(:direct_upload, :proposal, :documents, resource_type: nil)).not_to be_valid
    end

    it "should not be valid without resource_relation" do
      expect(build(:direct_upload, :proposal, :documents, resource_relation: nil)).not_to be_valid
    end

    it "should not be valid without attachment" do
      expect(build(:direct_upload, :proposal, :documents, attachment: nil)).not_to be_valid
    end

    it "should not be valid without user" do
      expect(build(:direct_upload, :proposal, :documents, user: nil)).not_to be_valid
    end
  end

  context "save_attachment" do
    it "should create all uploaded file versions" do
      proposal_document_direct_upload = build(:direct_upload, :proposal, :documents)

      expect{ proposal_document_direct_upload.save_attachment }.to eq(true)
    end

  end

  context "destroy_attachment" do
    it "should create all uploaded file versions" do

    end

  end


end