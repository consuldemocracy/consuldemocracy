require "rails_helper"

describe "Results" do
  let(:budget)  { create(:budget, :finished) }
  let(:group)   { create(:budget_group, budget: budget) }
  let(:heading) { create(:budget_heading, group: group, price: 1000) }
  let!(:investment) { create(:budget_investment, :selected, heading: heading, price: 200, ballot_lines_count: 900) }

  before do
    Budget::Result.new(budget, heading).calculate_winners
  end

  scenario "Back link redirects to budget page" do
    visit budget_results_path(budget)

    expect(page).to have_link("Go back", href: budget_path(budget))
  end

  scenario "Loads budget and heading by slug" do
    other_heading = create(:budget_heading, group: group, price: 1000)
    create(:budget_investment, :selected, heading: other_heading, price: 600, ballot_lines_count: 600)

    visit budget_results_path(budget.slug, heading_id: heading.slug)

    expect(page).to have_content("By district")
    expect(page).to have_selector("a.is-active", text: heading.name)

    within("#budget-investments-compatible") do
      expect(page).to have_content investment.title
    end
  end

  scenario "Do not show headings sidebar on single heading budgets" do
    visit budget_results_path(budget.slug, heading_id: heading.slug)

    expect(page).not_to have_content("By district")
    expect(page).not_to have_selector("a.is-active", text: heading.name)

    within("#budget-investments-compatible") do
      expect(page).to have_content investment.title
    end
  end
end
