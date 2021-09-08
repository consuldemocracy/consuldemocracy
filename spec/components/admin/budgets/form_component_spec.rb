require "rails_helper"

describe Admin::Budgets::FormComponent do
  describe "#voting_styles_select_options" do
    it "provides vote kinds" do
      types = [["Knapsack", "knapsack"], ["Approval", "approval"]]

      component = Admin::Budgets::FormComponent.new(double)

      expect(component.voting_styles_select_options).to eq(types)
    end
  end
end
