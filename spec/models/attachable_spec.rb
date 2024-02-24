require "rails_helper"

describe Attachable do
  it "stores attachments for the default tenant in the default folder" do
    file_path = build(:image).file_path

    expect(file_path).to include "storage/"
    expect(file_path).not_to include "storage//"
    expect(file_path).not_to include "tenants"
  end

  it "stores tenant attachments in a folder for the tenant" do
    allow(Tenant).to receive(:current_schema).and_return("image-master")

    expect(build(:image).file_path).to include "storage/tenants/image-master/"
  end

  context "file size validation" do
    it "is not applied when the image attachment has not changed" do
      image = create(:image, :proposal_image)

      expect(image.valid?).to be(true)

      Setting["uploads.images.max_size"] = 0.1

      expect(image.valid?).to be(true)
    end

    it "is applied when the image attachment changes" do
      image = create(:image, :proposal_image)

      expect(image.valid?).to be(true)

      Setting["uploads.images.max_size"] = 0.1
      image.attachment = Rack::Test::UploadedFile.new("spec/fixtures/files/clippy.png")

      expect(image.valid?).to be(false)
    end

    it "is not applied when the document attachment has not changed" do
      document = create(:document, :proposal_document)

      expect(document.valid?).to be(true)

      Setting["uploads.documents.max_size"] = 0.1

      expect(document.valid?).to be(true)
    end

    it "is applied when the document attachment changes" do
      document = create(:document, :proposal_document)

      expect(document.valid?).to be(true)

      Setting["uploads.documents.max_size"] = 0.1
      document.attachment = Rack::Test::UploadedFile.new("spec/fixtures/files/clippy.pdf")

      expect(document.valid?).to be(false)
    end
  end

  context "file content types validation" do
    it "is not applied when the image attachment has not changed" do
      image = create(:image, :proposal_image)

      expect(image.valid?).to be(true)

      Setting["uploads.images.content_types"] = "image/gif"

      expect(image.valid?).to be(true)
    end

    it "is applied when the image attachment changes" do
      image = create(:image, :proposal_image)

      expect(image.valid?).to be(true)

      Setting["uploads.images.content_types"] = "image/gif"
      image.attachment = Rack::Test::UploadedFile.new("spec/fixtures/files/clippy.png")

      expect(image.valid?).to be(false)
    end

    it "is not applied when the document attachment has not changed" do
      document = create(:document, :proposal_document)

      expect(document.valid?).to be(true)

      Setting["uploads.documents.content_types"] = "text/csv"

      expect(document.valid?).to be(true)
    end

    it "is applied when the document attachment changes" do
      document = create(:document, :proposal_document)

      expect(document.valid?).to be(true)

      Setting["uploads.documents.content_types"] = "text/csv"
      document.attachment = Rack::Test::UploadedFile.new("spec/fixtures/files/clippy.pdf")

      expect(document.valid?).to be(false)
    end
  end
end
