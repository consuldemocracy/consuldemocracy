require "rails_helper"

describe ImageSuggestionsController do
  let(:user) { create(:user) }

  before { sign_in user }

  describe "POST create" do
    let(:resource_type) { "Proposal" }
    let(:resource_id) { nil }
    let(:proposal_params) do
      {
        title: "Test Proposal",
        description: "This is a test proposal"
      }
    end

    it "successfully processes the request" do
      post :create, params: {
        resource_type: resource_type,
        resource_id: resource_id,
        proposal: proposal_params
      }, format: :js

      expect(response).to be_successful
    end

    it "processes resource attributes from params" do
      post :create, params: {
        resource_type: resource_type,
        proposal: proposal_params
      }, format: :js

      expect(response).to be_successful
    end

    it "handles namespaced resource types" do
      post :create, params: {
        resource_type: "Budget::Investment",
        budget_investment: { title: "Test Investment" }
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
    let(:resource_type) { "Proposal" }
    let(:resource_id) { nil }
    let(:photo_id) { "12345" }
    let(:uploaded_file) do
      ActionDispatch::Http::UploadedFile.new(
        tempfile: fixture_file_upload("clippy.jpg"),
        filename: "test.jpg",
        type: "image/jpeg"
      )
    end

    before do
      allow(ImageSuggestions::Pexels).to receive(:download).with(photo_id).and_return(uploaded_file)
    end

    context "when download succeeds" do
      let(:direct_upload) do
        instance_double(DirectUpload, valid?: true, relation: relation, errors: errors,
                                      resource_relation: "image")
      end
      let(:blob) { double("blob", save!: true) }
      let(:attachment_changes) { { "attachment" => double("change", upload: true) } }
      let(:relation) do
        instance_double(Image, cached_attachment: "cached", attachment_file_name: "test.jpg",
                               attachment: attachment, attachment_changes: attachment_changes)
      end
      let(:attachment) { double("attachment", blob: blob) }
      let(:errors) { instance_double(ActiveModel::Errors, :[] => []) }

      before do
        allow(DirectUpload).to receive(:new).and_return(direct_upload)
        allow(direct_upload.relation).to receive(:set_cached_attachment_from_attachment)
        allow(controller).to receive(:polymorphic_path).and_return("/images/1")
      end

      it "creates a direct upload with the downloaded image" do
        allow(direct_upload).to receive(:save_attachment)

        expect(DirectUpload).to receive(:new).with(
          hash_including(
            resource_type: resource_type,
            resource_relation: "image",
            attachment: uploaded_file,
            user: user
          )
        ).and_return(direct_upload)

        post :attach, params: {
          id: photo_id,
          resource_type: resource_type,
          resource_id: resource_id
        }
      end

      it "saves the attachment and returns success response" do
        expect(direct_upload).to receive(:save_attachment)
        expect(direct_upload.relation).to receive(:set_cached_attachment_from_attachment)

        post :attach, params: {
          id: photo_id,
          resource_type: resource_type,
          resource_id: resource_id
        }

        expect(response).to have_http_status(:success)
        json_response = response.parsed_body
        expect(json_response).to include("cached_attachment", "filename", "destroy_link", "attachment_url")
      end
    end

    context "when download fails" do
      before do
        allow(ImageSuggestions::Pexels).to receive(:download)
          .and_raise(ImageSuggestions::Pexels::PexelsError, "Download failed")
      end

      it "returns error response" do
        post :attach, params: {
          id: photo_id,
          resource_type: resource_type
        }

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = response.parsed_body
        expect(json_response["errors"]).to eq("Download failed")
      end
    end

    context "when Pexels::APIError is raised" do
      before do
        allow(ImageSuggestions::Pexels).to receive(:download)
          .and_raise(Pexels::APIError, "Download failed")
      end

      it "returns error response with message" do
        post :attach, params: {
          id: photo_id,
          resource_type: resource_type
        }

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = response.parsed_body
        expect(json_response["errors"]).to eq("Download failed")
      end
    end

    context "respects the file limits" do
      let(:direct_upload) { instance_double(DirectUpload, valid?: false, errors: errors) }
      let(:errors) { instance_double(ActiveModel::Errors, :[] => ["File is too large"]) }

      before do
        allow(DirectUpload).to receive(:new).and_return(direct_upload)
      end

      it "returns validation errors" do
        post :attach, params: {
          id: photo_id,
          resource_type: resource_type
        }

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = response.parsed_body
        expect(json_response["errors"]).to eq("File is too large")
      end
    end
  end
end
