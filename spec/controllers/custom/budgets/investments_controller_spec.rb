require "rails_helper"

describe Budgets::InvestmentsController do
  describe "GET show" do
    let(:investment) { create(:budget_investment) }

    it "has custom order for comments" do
      get :show, params: { budget_id: investment.budget.id, id: investment.id }
      expect(controller.valid_orders).to eq %w[most_voted newest oldest]
    end
  end
end
