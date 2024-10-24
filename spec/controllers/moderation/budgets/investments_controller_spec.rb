require "rails_helper"

describe Moderation::Budgets::InvestmentsController do
  before { sign_in create(:moderator).user }

  describe "GET index" do
    it "raises an exception when the feature is disabled" do
      Setting["process.budgets"] = nil

      expect { get :index }.to raise_exception(FeatureFlags::FeatureDisabled)
    end
  end

  describe "PUT moderate" do
    it "keeps query parameters while using protected redirects" do
      id = create(:budget_investment).id

      get :moderate, params: { resource_ids: [id], filter: "all", host: "evil.dev" }

      expect(response).to redirect_to "/moderation/budget_investments?filter=all&resource_ids%5B%5D=#{id}"
    end
  end
end
