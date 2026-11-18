require "rails_helper"

describe ClassificationSuggestionsController do
  let(:user) { create(:user) }
  let(:llm_response) do
    ClassificationSuggestions::Llm::Client::Response.new.tap do |response|
      response.categories = ["Culture"]
      response.tags = ["parks"]
      response.sdgs = [{ "code" => "3", "reason" => "Health related" }]
    end
  end

  before do
    sign_in user
    Setting["llm.provider"] = "OpenAI"
    Setting["llm.model"] = "gpt-4o"
    Setting["llm.use_ai_classification_suggestions"] = true
    allow(ClassificationSuggestions::Llm::Client).to receive(:call).and_return(llm_response)
  end

  describe "POST create" do
    let(:proposal_params) do
      {
        translations_attributes: {
          "0" => { title: "Test Proposal", description: "A description", summary: "A summary" }
        },
        tag_list: "Environment,\"Parks, Gardens\"",
        related_sdg_list: "3, 11.2"
      }
    end

    it "returns JSON suggestions for a proposal" do
      post :create, params: {
        resource_type: "Proposal",
        proposal: proposal_params
      }, format: :json

      expect(response).to be_successful
      expect(ClassificationSuggestions::Llm::Client).to have_received(:call).with(
        hash_including(
          title: "Test Proposal",
          description: "A description",
          summary: "A summary",
          selected_tags: match_array(["Environment", "Parks, Gardens"]),
          selected_sdgs: ["3", "11.2"],
          resource_type: "Proposal"
        )
      )

      body = response.parsed_body
      expect(body["categories"]).to eq(["Culture"])
      expect(body["tags"]).to eq(["parks"])
      expect(body["sdgs"]).to eq([{ "code" => "3", "reason" => "Health related" }])
      expect(body["errors"]).to eq([])
    end

    it "returns JSON suggestions for a budget investment" do
      post :create, params: {
        resource_type: "Budget::Investment",
        budget_investment: {
          translations_attributes: {
            "0" => { title: "Test Investment", description: "Investment description" }
          }
        }
      }, format: :json

      expect(response).to be_successful
      expect(ClassificationSuggestions::Llm::Client).to have_received(:call).with(
        title: "Test Investment",
        description: "Investment description",
        summary: nil,
        selected_tags: [],
        selected_sdgs: [],
        locale: I18n.locale,
        resource_type: "Budget::Investment"
      )
    end

    it "falls back to flat title and description attributes" do
      post :create, params: {
        resource_type: "Proposal",
        proposal: { title: "Flat title", description: "Flat description", summary: "Flat summary" }
      }, format: :json

      expect(response).to be_successful
      expect(ClassificationSuggestions::Llm::Client).to have_received(:call).with(
        hash_including(
          title: "Flat title",
          description: "Flat description",
          summary: "Flat summary"
        )
      )
    end

    it "raises an error when resource params are missing" do
      expect do
        post :create, params: { resource_type: "Proposal" }, format: :json
      end.to raise_error(ActionController::ParameterMissing)
    end

    context "when the user is not signed in" do
      before { sign_out user }

      it "redirects to sign in" do
        post :create, params: {
          resource_type: "Proposal",
          proposal: proposal_params
        }, format: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when rate limit is exceeded" do
      before { ClassificationSuggestionsController.cache_store.clear }

      it "returns a rate limit error message" do
        10.times do
          post :create, params: {
            resource_type: "Proposal",
            proposal: proposal_params
          }, format: :json
        end

        post :create, params: {
          resource_type: "Proposal",
          proposal: proposal_params
        }, format: :json

        expect(response).to be_successful
        expect(response.parsed_body["errors"]).to include(
          "Please wait a few minutes before generating new suggestions."
        )
      end
    end
  end
end
