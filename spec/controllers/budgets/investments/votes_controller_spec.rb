require "rails_helper"

describe Budgets::Investments::VotesController do
  let(:user) { create(:user) }
  let(:budget) { create(:budget, :selecting) }
  let(:investment) { create(:budget_investment, budget: budget) }
  let(:vote) { create(:vote, votable: investment, voter: user) }
  before { sign_in user }

  describe "DELETE destroy" do
    it "raises an exception when the remove supports feature is disabled" do
      Setting["feature.remove_investments_supports"] = false

      expect do
        delete :destroy, xhr: true, params: { budget_id: budget, investment_id: investment, id: vote }
      end.to raise_exception(FeatureFlags::FeatureDisabled)
    end
  end

  describe "POST create" do
    it "is not affected by the remove supports feature" do
      Setting["feature.remove_investments_supports"] = false

      post :create, params: { budget_id: budget, investment_id: investment }

      expect(response).to redirect_to budget_investments_path(heading_id: investment.heading.id)
    end
  end
end
