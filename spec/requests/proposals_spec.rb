require "rails_helper"

describe "Proposals API" do
  around do |example|
    ActionController::Base.with(allow_forgery_protection: true) { example.run }
  end

  describe "POST create" do
    it "creates valid proposals" do
      sign_in(create(:user, document_number: "13572468A"))

      post "/proposals", as: :json, params: {
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

      post "/proposals", as: :json, params: { proposal: { title: "" }}

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body["errors"]).to be_present
    end

    it "doesn't authorize anonymous users" do
      post "/proposals", as: :json, params: {
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

  describe "PATCH update" do
    let(:proposal) { create(:proposal) }

    it "updates a valid proposal" do
      sign_in(proposal.author)

      patch "/proposals/#{proposal.to_param}", as: :json, params: { proposal: { title: "Update!" }}

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["title"]).to eq "Update!"
    end

    it "does no update an invalid proposal" do
      sign_in(proposal.author)

      patch "/proposals/#{proposal.to_param}", as: :json, params: {
        proposal: {
          translations_attributes: {
            "0" => {
              locale: "en",
              id: proposal.translations.first.id,
              title: "",
              summary: ""
            }
          }
        }
      }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body["errors"]).to be_present
    end

    it "forbids access to other users" do
      sign_in(create(:user))

      patch "/proposals/#{proposal.to_param}", as: :json, params: { proposal: { title: "Update!" }}

      expect(response).to have_http_status(:forbidden)
      expect(response.parsed_body["error"]).to include "You do not have permission"
    end
  end
end
