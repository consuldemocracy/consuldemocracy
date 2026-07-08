require "rails_helper"

describe DirectUploadsController do
  render_views
  before { sign_in create(:user) }

  describe "POST create" do
    let(:upload_params) do
      {
        resource_type: "Proposal",
        resource_relation: "image",
        title: "My Title"
      }
    end

    it "preserves a title provided in the request" do
      post :create, params: {
        direct_upload: upload_params,
        attachment: fixture_file_upload("clippy.jpg")
      }, format: :json

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["content"]).to include('value="My Title"')
    end

    it "uses the filename as title when none is provided" do
      post :create, params: {
        direct_upload: upload_params.except(:title),
        attachment: fixture_file_upload("clippy.jpg")
      }, format: :json

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["content"]).to include('value="clippy.jpg"')
    end
  end
end
