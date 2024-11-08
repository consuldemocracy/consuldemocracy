require "rails_helper"

describe Users::BudgetInvestmentTableActionsComponent do
  let(:user) { create(:user, :level_two) }
  let(:budget) { create(:budget, :accepting) }
  let(:investment) { create(:budget_investment, budget: budget, author: user, title: "User investment") }

  describe "#edit_link" do
    it "generates an aria-label attribute" do
      sign_in(user)

      render_inline Users::BudgetInvestmentTableActionsComponent.new(investment)

      expect(page).to have_link count: 1
      expect(page).to have_link "Edit"
      expect(page).to have_css "a[aria-label='Edit User investment']"
    end
  end

  describe "#destroy_button" do
    it "generates an aria-label attribute" do
      sign_in(user)

      render_inline Users::BudgetInvestmentTableActionsComponent.new(investment)

      expect(page).to have_button count: 1
      expect(page).to have_button "Delete"
      expect(page).to have_css "button[aria-label='Delete User investment']"
    end
  end
end
