require "rails_helper"

describe Budgets::Executions::FiltersComponent do
  let(:budget) { create(:budget) }
  let(:component) { Budgets::Executions::FiltersComponent.new(budget, []) }

  describe "#options_for_milestone_tags" do
    it "does not return duplicate records for tags in different contexts" do
      create(:budget_investment, :winner, budget: budget, milestone_tag_list: ["Multiple"])
      create(:budget_investment, :winner, budget: budget, milestone_tag_list: ["Multiple"])
      create(:budget_investment, :winner, budget: budget, milestone_tag_list: ["Dup"], tag_list: ["Dup"])

      expect(component.options_for_milestone_tags).to eq [["Dup (1)", "Dup"], ["Multiple (2)", "Multiple"]]
    end
  end
end
