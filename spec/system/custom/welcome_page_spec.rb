require "rails_helper"

describe "Welcome page" do
  context "Feeds" do
    scenario "Show published budgets info" do
      budget = create(:budget, :accepting)
      finished = create(:budget, :finished)
      draft = create(:budget, :drafting)
      draft.current_phase.update!(description: "Budget in draft mode")

      visit root_path

      within "#feed_budgets" do
        expect(page).to have_content budget.name
        expect(page).to have_content budget.formatted_total_headings_price
        expect(page).to have_content budget.current_phase.name
        expect(page).to have_content "#{budget.current_enabled_phase_number}/#{budget.enabled_phases_amount}"
        expect(page).to have_content "#{budget.start_date.to_date}"
        expect(page).to have_content "#{budget.end_date.to_date}"
        expect(page).to have_content budget.description
        expect(page).to have_content "See this budget", count: 2
        expect(page).to have_link href: budget_path(budget)
        expect(page).to have_content finished.name
        expect(page).to have_content finished.formatted_total_headings_price
        expect(page).to have_content "Completed"
        expect(page).to have_content "#{finished.start_date.to_date}"
        expect(page).to have_content "#{finished.end_date.to_date}"
        expect(page).to have_content finished.description
        expect(page).to have_link href: budget_path(finished)
        expect(page).not_to have_content draft.name
        expect(page).not_to have_content draft.description
        expect(page).not_to have_link href: budget_path(draft)
      end
    end
  end
end
