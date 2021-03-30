require "rails_helper"

describe Budgets::InvestmentsController do
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

    it "raises an error if heading slug is not found" do
      expect do
        get :show, params: { budget_id: investment.budget.id, id: investment.id, heading_id: "wrong_heading" }
      end.to raise_error ActiveRecord::RecordNotFound
    end

    it "raises an error if heading id is not found" do
      expect do
        get :show, params: { budget_id: investment.budget.id, id: investment.id, heading_id: 0 }
      end.to raise_error ActiveRecord::RecordNotFound
    end
  end
end
