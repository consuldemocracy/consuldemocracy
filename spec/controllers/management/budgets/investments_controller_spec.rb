require "rails_helper"

describe Management::Budgets::InvestmentsController do
  before do
    manager = create(:manager)
    sign_in(manager.user)
    session[:manager] = { login: "manager_user_#{manager.user.id}" }
    login_managed_user(create(:user, :level_two))
  end

  describe "GET index" do
    it "raises an exception when the feature is disabled" do
      Setting["process.budgets"] = false

      expect do
        get :index, params: { budget_id: create(:budget).id }
      end.to raise_exception(FeatureFlags::FeatureDisabled)
    end
  end

  describe "GET show" do
    let(:investment) { create(:budget_investment) }

    it "raises an error if budget slug is not found" do
      expect do
        get :show, params: { budget_id: "wrong_budget", id: investment.id }
      end.to raise_error ActiveRecord::RecordNotFound
    end

    it "raises an error if budget id is not found" do
      expect do
        get :show, params: { budget_id: 0, id: investment.id }
      end.to raise_error ActiveRecord::RecordNotFound
    end
  end
end
