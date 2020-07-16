require "rails_helper"

describe BudgetsHelper do
  describe "#budget_voting_styles_select_options" do
    it "provides vote kinds" do
      types = [
        ["Knapsack", "knapsack"],
        ["Approval", "approval"]
      ]

      expect(budget_voting_styles_select_options).to eq(types)
    end
  end
end
