require "rails_helper"

describe "Admin budget investments", :admin do
  context "Show" do
    scenario "Show feasible explanation" do
      budget_investment = create(:budget_investment, :feasible, feasibility_explanation: "This is awesome!")

      visit admin_budget_budget_investments_path(budget_investment.budget)

      within_window(window_opened_by { click_link budget_investment.title }) do
        expect(page).to have_content("Feasible")
        expect(page).to have_content("This is awesome!")
      end
    end
  end
end
