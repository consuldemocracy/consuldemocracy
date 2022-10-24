require "rails_helper"

describe ActiveStorage::DirectUploadsController do
  describe "POST create" do
    it "doesn't allow anonymous users to upload files" do
      blob_attributes = { filename: "logo.pdf", byte_size: 30000, checksum: SecureRandom.hex(32) }

      post :create, params: { blob: blob_attributes }

      expect(ActiveStorage::Blob.count).to eq 0
      expect(response).to be_unauthorized
    end
  end
end
