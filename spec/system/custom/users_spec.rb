require "rails_helper"

describe "Users" do
  describe "Show (public page)" do
    let(:user) { create(:user) }

    scenario "Show expired message if user can not edit a budget investment" do
      user = create(:user, :level_two)
      budget = create(:budget, :accepting)
      budget_investment = create(:budget_investment, author_id: user.id, budget: budget)

      login_as(user)
      visit user_path(user)

      within("#budget_investment_#{budget_investment.id}") do
        expect(page).to have_link "Edit"
      end

      budget.update!(phase: "finished")
      visit user_path(user)

      within("#budget_investment_#{budget_investment.id}") do
        expect(page).to have_content "Expired"
        expect(page).not_to have_link "Edit"
      end
    end
  end
end
