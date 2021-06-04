require "rails_helper"

describe "Welcome page" do
  context "Feeds" do
    scenario "Show published budgets info" do
      budget = create(:budget, :accepting)
      finished = create(:budget, :finished)
      group = create(:budget_group, budget: finished)
      create(:budget_heading, group: group, price: 10000)
      hide_money = create(:budget, :valuating, :hide_money)
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
        expect(page).to have_content "See this budget", count: 3
        expect(page).to have_link href: budget_path(budget)
        expect(page).to have_content finished.name
        expect(page).to have_content finished.formatted_total_headings_price
        expect(page).to have_content "COMPLETED"
        expect(page).to have_content "€", count: 1
        expect(page).to have_content "#{finished.start_date.to_date}"
        expect(page).to have_content "#{finished.end_date.to_date}"
        expect(page).to have_content finished.description
        expect(page).to have_link href: budget_path(finished)
        expect(page).not_to have_content draft.name
        expect(page).not_to have_content draft.description
        expect(page).not_to have_link href: budget_path(draft)
        expect(page).to have_content hide_money.name
        expect(page).to have_content "#{hide_money.start_date.to_date}"
        expect(page).to have_content "#{hide_money.end_date.to_date}"
        expect(page).to have_content hide_money.description
        expect(page).to have_link href: budget_path(hide_money)
      end
    end
  end
end
