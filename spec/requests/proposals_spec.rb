require "rails_helper"

describe "Proposals API" do
  around do |example|
    ActionController::Base.with(allow_forgery_protection: true) { example.run }
  end

  describe "GET show" do
    it "shows proposals" do
      proposal = create(:proposal)
      get "/proposals/#{proposal.to_param}", as: :json

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["id"]).to be_present
      expect(response.parsed_body["title"]).to be_present
    end
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

  describe "POST vote" do
    let(:proposal) { create(:proposal) }

    it "creates a vote for verified users" do
      sign_in(create(:user, :level_two))

      post "/proposals/#{proposal.to_param}/vote", as: :json

      expect(response).to have_http_status(:created)
      expect(response.parsed_body["cached_votes_up"]).to eq 1
    end

    it "doesn't authorize anonymous users" do
      post "/proposals/#{proposal.to_param}/vote", as: :json

      expect(response).to have_http_status(:unauthorized)
      expect(response.parsed_body["error"]).to eq "You must sign in or register to continue."
    end
  end

  describe "PATCH retire" do
    let(:proposal) { create(:proposal) }

    it "retires a proposal with an explanation" do
      sign_in(proposal.author)

      patch "/proposals/#{proposal.to_param}/retire", as: :json, params: {
        proposal: { retired_reason: "duplicated", retired_explanation: "Submitted twice." }
      }

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["retired_explanation"]).to eq "Submitted twice."
    end

    it "does not retire a proposal without a reason" do
      sign_in(proposal.author)

      patch "/proposals/#{proposal.to_param}/retire", as: :json, params: {
        proposal: { retired_explanation: "Submitted twice." }
      }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body["errors"]).to be_present
    end

    it "forbids access to other users" do
      sign_in(create(:user))

      patch "/proposals/#{proposal.to_param}/retire", as: :json, params: {
        proposal: { retired_reason: "duplicated", retired_explanation: "Submitted twice." }
      }

      expect(response).to have_http_status(:forbidden)
      expect(response.parsed_body["error"]).to include "You do not have permission"
    end
  end

  describe "PATCH publish" do
    let(:proposal) { create(:proposal, :draft) }

    it "publishes a proposal" do
      sign_in(proposal.author)

      patch "/proposals/#{proposal.to_param}/publish", as: :json

      expect(response).to have_http_status(:ok)
    end

    it "forbids access to other users" do
      sign_in(create(:user))

      patch "/proposals/#{proposal.to_param}/publish", as: :json

      expect(response).to have_http_status(:forbidden)
      expect(response.parsed_body["error"]).to include "You do not have permission"
    end
  end
end
