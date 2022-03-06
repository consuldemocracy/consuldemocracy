require "rails_helper"

describe BudgetExecutionsHelper do
  describe "#options_for_milestone_tags" do
    let(:budget) { create(:budget) }

    it "does not return duplicate records for tags in different contexts" do
      create(:budget_investment, :winner, budget: budget, milestone_tag_list: ["Multiple"])
      create(:budget_investment, :winner, budget: budget, milestone_tag_list: ["Multiple"])
      create(:budget_investment, :winner, budget: budget, milestone_tag_list: ["Dup"], tag_list: ["Dup"])

      @budget = budget

      expect(options_for_milestone_tags).to eq [["Dup (1)", "Dup"], ["Multiple (2)", "Multiple"]]
    end
  end
end
