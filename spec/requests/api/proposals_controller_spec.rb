require "rails_helper"

describe Api::ProposalsController do
  describe "POST create" do
    it "creates valid proposals" do
      sign_in(create(:user, document_number: "13572468A"))

      post "/api/proposals", as: :json, params: {
        proposal: {
          title: "I'm responsible",
          summary: "I have a document number",
          description: "But you won't see my document number",
          terms_of_service: "1"
        }
      }

      expect(response).to have_http_status(:created)
      expect(response.parsed_body["id"]).to be_present
      expect(response.parsed_body["title"]).to eq "I'm responsible"
    end

    it "rejects invalid proposals" do
      sign_in(create(:user, document_number: "13572468A"))

      post "/api/proposals", as: :json, params: { proposal: { title: "" }}

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body["errors"]["title"]).to include "can't be blank"
    end

    it "rejects invalid nested translations using the attribute names" do
      sign_in(create(:user, document_number: "13572468A"))

      post "/api/proposals", as: :json, params: {
        proposal: {
          translations_attributes: {
            "0" => { locale: "en", title: "", summary: "" }
          },
          terms_of_service: "1"
        }
      }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body["errors"].keys).to include("translations.title", "translations.summary")
      expect(response.parsed_body["errors"]["translations.title"]).to include "can't be blank"
      expect(response.parsed_body["errors"]["translations.summary"]).to include "can't be blank"
    end

    it "doesn't authorize anonymous users" do
      post "/api/proposals", as: :json, params: {
        proposal: {
          title: "I'm responsible",
          summary: "I have a document number",
          description: "But you won't see my document number",
          terms_of_service: "1"
        }
      }

      expect(response).to have_http_status(:unauthorized)
      expect(response.parsed_body["error"]).to eq "You must sign in or register to continue."
    end
  end
end
