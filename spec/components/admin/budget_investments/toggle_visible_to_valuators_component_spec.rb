require "rails_helper"

describe Admin::BudgetInvestments::ToggleVisibleToValuatorsComponent, :admin do
  describe "aria-pressed attribute" do
    it "is true for investments visible to valuators" do
      investment = create(:budget_investment, :visible_to_valuators)

      render_inline Admin::BudgetInvestments::ToggleVisibleToValuatorsComponent.new(investment)

      expect(page).to have_css "[aria-pressed=true]"
    end

    it "is true for investments invisible to valuators" do
      investment = create(:budget_investment, :invisible_to_valuators)

      render_inline Admin::BudgetInvestments::ToggleVisibleToValuatorsComponent.new(investment)

      expect(page).to have_css "[aria-pressed=false]"
    end
  end
end
