require "rails_helper"

describe ImageSuggestionsController do
  let(:user) { create(:user) }

  before { sign_in user }

  describe "POST create" do
    let(:resource_type) { "Budget::Investment" }
    let(:budget_investment_params) do
      {
        translations_attributes: {
          "0" => { title: "Test Investment", description: "This is a test investment" }
        }
      }
    end

    it "successfully processes the request with resource params" do
      post :create, params: {
        resource_type: resource_type,
        budget_investment: budget_investment_params
      }, format: :js

      expect(response).to be_successful
    end

    it "handles namespaced resource types" do
      post :create, params: {
        resource_type: "Proposal",
        proposal: {
          translations_attributes: {
            "0" => { title: "Test Proposal", description: "" }
          }
        }
      }, format: :js

      expect(response).to be_successful
    end

    it "raises an error when resource params are missing" do
      expect do
        post :create, params: {
          resource_type: resource_type
        }, format: :js
      end.to raise_error(ActionController::ParameterMissing)
    end
  end

  describe "POST attach" do
    let(:resource_type) { "Budget::Investment" }
    let(:photo_id) { "12345" }
    let(:uploaded_file) { fixture_file_upload("clippy.jpg") }

    before do
      allow(ImageSuggestions::Pexels).to receive(:download).with(photo_id).and_return(uploaded_file)
    end

    context "when download succeeds and DirectUpload is valid" do
      it "returns success and JSON with attachment data" do
        post :attach, params: { id: photo_id, resource_type: resource_type }

        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json).to include("cached_attachment", "filename", "destroy_link", "attachment_url")
      end
    end

    context "when download fails" do
      before do
        allow(ImageSuggestions::Pexels).to receive(:download)
          .and_raise(ImageSuggestions::Pexels::PexelsError, "Download failed")
      end

      it "returns error response" do
        post :attach, params: { id: photo_id, resource_type: resource_type }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body["errors"]).to eq "Download failed"
      end
    end

    context "when Pexels::APIError is raised" do
      before do
        allow(ImageSuggestions::Pexels).to receive(:download)
          .and_raise(Pexels::APIError, "Download failed")
      end

      it "returns error response with message" do
        post :attach, params: { id: photo_id, resource_type: resource_type }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body["errors"]).to eq "Download failed"
      end
    end

    context "when DirectUpload is invalid" do
      before do
        allow(ImageSuggestions::Pexels).to receive(:download).with(photo_id)
                                                             .and_return(fixture_file_upload("empty.pdf"))
      end

      it "returns 422 with validation errors in JSON" do
        post :attach, params: { id: photo_id, resource_type: resource_type }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body["errors"]).to be_present
      end
    end
  end
end
