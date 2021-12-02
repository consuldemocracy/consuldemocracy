require "rails_helper"

describe Moderation::UsersController do
  before { sign_in create(:moderator).user }
  let(:user) { create(:user, email: "user@consul.dev") }

  describe "PUT hide" do
    it "keeps query parameters while using protected redirects" do
      user = create(:user, email: "user@consul.dev")

      get :hide, params: { id: user, name_or_email: "user@consul.dev", host: "evil.dev" }

      expect(response).to redirect_to "/moderation/users?name_or_email=user%40consul.dev"
    end
  end

  describe "PUT block" do
    it "keeps query parameters while using protected redirects" do
      user = create(:user, email: "user@consul.dev")

      get :block, params: { id: user, search: "user@consul.dev", host: "evil.dev" }

      expect(response).to redirect_to "/moderation/users?search=user%40consul.dev"
    end

    it "redirects to the index of the section where it was called with a notice" do
      proposal = create(:proposal, author: user)
      request.env["HTTP_REFERER"] = proposal_path(proposal)

      put :block, params: { id: user }

      expect(response).to redirect_to proposals_path
      expect(flash[:notice]).to eq "The user has been blocked. All contents authored by this user have been hidden."
    end

    it "redirects to the index with a nested resource" do
      investment = create(:budget_investment, author: user)
      request.env["HTTP_REFERER"] = budget_investment_path(investment.budget, investment)

      put :block, params: { id: user }

      expect(response).to redirect_to budget_investments_path(investment.budget)
    end
  end
end
