require "rails_helper"

describe ProposalsController do
  describe "GET index" do
    it "raises an exception when the feature is disabled" do
      Setting["process.proposals"] = false

      expect { get :index }.to raise_exception(FeatureFlags::FeatureDisabled)
    end
  end

  describe "PATCH update" do
    before { InvisibleCaptcha.timestamp_enabled = false }
    after { InvisibleCaptcha.timestamp_enabled = true }

    it "does not delete other proposal's map location" do
      proposal = create(:proposal)
      other_proposal = create(:proposal, :with_map_location)

      sign_in(proposal.author)

      patch :update, params: {
        proposal: {
          map_location_attributes: { id: other_proposal.map_location.id },
          responsible_name: "Skinny Fingers"
        },
        id: proposal.id
      }

      expect(proposal.reload.responsible_name).to eq "Skinny Fingers"
      expect(other_proposal.reload.map_location).not_to be nil
    end
  end

  describe "POST create" do
    before { InvisibleCaptcha.timestamp_enabled = false }
    after { InvisibleCaptcha.timestamp_enabled = true }

    it "assigns the responsible name to the proposal" do
      sign_in(create(:user, document_number: "13572468A"))

      post :create, params: {
        proposal: {
          translations_attributes: {
            "0" => {
              locale: "en",
              title: "I'm responsible",
              summary: "I have a document number",
              description: "But you won't see my document number"
            }
          },
          terms_of_service: "1"
        }
      }

      expect(Proposal.last.responsible_name).to eq "13572468A"
    end
  end
end
