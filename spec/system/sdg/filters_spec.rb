require "rails_helper"

describe "SDG filters", :js do
  before do
    Setting["feature.sdg"] = true
    Setting["sdg.process.budgets"] = true
  end

  scenario "generates links to index with nested resources" do
    budget = create(:budget)
    create(:budget_investment, budget: budget, title: "School's out", sdg_goals: [SDG::Goal[4]])
    create(:budget_investment, budget: budget, title: "We are the world", sdg_goals: [SDG::Goal[1]])

    visit budget_investments_path(budget)

    within("#sidebar") { click_link "1. No Poverty" }

    expect(page).not_to have_content "School's out"
    expect(page).to have_content "We are the world"

    within("#sidebar") { click_link "4. Quality Education" }

    expect(page).to have_content "School's out"
    expect(page).not_to have_content "We are the world"
  end
end
