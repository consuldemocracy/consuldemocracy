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

  describe "PATCH update" do
    let(:proposal) { create(:proposal, title: "Original title") }

    it "updates a valid proposal" do
      sign_in(proposal.author)

      patch "/api/proposals/#{proposal.id}", as: :json, params: { proposal: { title: "Update!" }}

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["title"]).to eq "Update!"
    end

    it "adds a new translation when using a different locale" do
      sign_in(proposal.author)

      patch "/api/proposals/#{proposal.id}?locale=es", as: :json, params: {
        proposal: {
          title: "Nuevo texto",
          summary: "En otro idioma",
          description: "Y con correcciones de algunos fallos"
        }
      }

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["title"]).to eq "Nuevo texto"
      expect(proposal.reload.translations.pluck(:locale, :title).to_h).to eq(
        { "en" => "Original title", "es" => "Nuevo texto" }
      )
    end

    it "does not update an invalid proposal" do
      sign_in(proposal.author)
      original_title = proposal.title

      patch "/api/proposals/#{proposal.id}", as: :json, params: { proposal: { title: "", summary: "" }}

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body["errors"].keys).to eq ["title", "summary"]
      expect(response.parsed_body["errors"]["title"]).to include "can't be blank"
      expect(proposal.reload.title).to eq original_title
    end

    it "does not delete the only translation" do
      sign_in(proposal.author)

      patch "/api/proposals/#{proposal.id}", as: :json, params: {
        proposal: {
          translations_attributes: {
            "0" => { id: proposal.translations.first.id, _destroy: "1" }
          }
        }
      }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body["errors"]["base"]).to eq [
        "It's mandatory to provide at least one translation"
      ]
      expect(proposal.reload.translations).to be_present
    end

    it "forbids access to other users" do
      sign_in(create(:user))

      patch "/api/proposals/#{proposal.id}", as: :json, params: { proposal: { title: "Update!" }}

      expect(response).to have_http_status(:forbidden)
      expect(response.parsed_body["error"]).to include "You do not have permission"
    end
  end

  describe "PATCH retire" do
    let(:proposal) { create(:proposal) }

    it "retires a proposal with an explanation" do
      sign_in(proposal.author)

      patch "/api/proposals/#{proposal.id}/retire", as: :json, params: {
        proposal: { retired_reason: "duplicated", retired_explanation: "Submitted twice." }
      }

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["retired_explanation"]).to eq "Submitted twice."
    end

    it "does not retire a proposal without a reason" do
      sign_in(proposal.author)

      patch "/api/proposals/#{proposal.id}/retire", as: :json, params: {
        proposal: { retired_explanation: "Submitted twice." }
      }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body["errors"]).to be_present
    end

    it "forbids access to other users" do
      sign_in(create(:user))

      patch "/api/proposals/#{proposal.id}/retire", as: :json, params: {
        proposal: { retired_reason: "duplicated", retired_explanation: "Submitted twice." }
      }

      expect(response).to have_http_status(:forbidden)
      expect(response.parsed_body["error"]).to include "You do not have permission"
    end
  end
end
