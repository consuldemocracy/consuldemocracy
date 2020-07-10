require "rails_helper"

describe "Welcome page" do
  context "Feeds" do
    scenario "Show budgets info" do
      budget = create(:budget)

      visit root_path

      within "#feed_budgets" do
        expect(page).to have_content budget.name
        expect(page).to have_content budget.formatted_total_headings_price
        expect(page).to have_content budget.current_phase.name
        expect(page).to have_content "#{budget.current_enabled_phase_number}/#{budget.enabled_phases_amount}"
        expect(page).to have_content "#{budget.start_date.to_date}"
        expect(page).to have_content "#{budget.end_date.to_date}"
        expect(page).to have_content budget.description
        expect(page).to have_content "See this budget"
        expect(page).to have_link href: budget_path(budget)
      end
    end
  end
end
