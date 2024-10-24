require "rails_helper"

describe ActiveStorage::DiskController do
  describe "PUT update" do
    it "doesn't allow anonymous users to upload files" do
      blob = create(:active_storage_blob)

      put :update, params: { encoded_token: blob.signed_id }

      expect(response).to be_unauthorized
    end
  end
end
