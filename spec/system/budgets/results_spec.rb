require "rails_helper"

describe "Results" do
  let(:budget)  { create(:budget, :finished) }
  let(:group)   { create(:budget_group, budget: budget) }
  let(:heading) { create(:budget_heading, group: group, price: 1000) }

  before do
    create(:budget_investment, :selected, title: "First selected", heading: heading, price: 200, ballot_lines_count: 900)
    create(:budget_investment, :selected, title: "Second selected", heading: heading, price: 300, ballot_lines_count: 800)
    create(:budget_investment, :incompatible, title: "Incompatible investment", heading: heading, price: 500, ballot_lines_count: 700)
    create(:budget_investment, :selected, title: "Exceeding price", heading: heading, price: 600, ballot_lines_count: 600)

    Budget::Result.new(budget, heading).calculate_winners
  end

  scenario "No links to budget results with results disabled" do
    budget.update!(results_enabled: false)

    visit budgets_path

    expect(page).not_to have_link "See results"

    visit budget_path(budget)

    expect(page).not_to have_link "See results"

    visit budget_executions_path(budget)

    expect(page).not_to have_link "See results"
  end

  scenario "Diplays winner investments" do
    create(:budget_heading, group: group)

    visit budget_path(budget)
    click_link "See results"

    expect(page).to have_selector("a.is-active", text: heading.name)

    within("#budget-investments-compatible") do
      expect(page).to have_content "First selected"
      expect(page).to have_content "Second selected"
      expect(page).not_to have_content "Incompatible investment"
      expect(page).not_to have_content "Exceeding price"

      expect("First selected").to appear_before("Second selected")
    end
  end

  scenario "Show non winner & incompatible investments" do
    visit budget_path(budget)
    click_link "See results"
    click_link "Show all"

    within("#budget-investments-compatible") do
      expect(page).to have_content "First selected"
      expect(page).to have_content "Second selected"
      expect(page).to have_content "Exceeding price"

      expect("First selected").to appear_before("Second selected")
      expect("Second selected").to appear_before("Exceeding price")
    end

    within("#budget-investments-incompatible") do
      expect(page).to have_content "Incompatible"
    end
  end

  scenario "Does not show price and available budget when hide money" do
    budget.update!(voting_style: "approval", hide_money: true)

    visit budget_results_path(budget)

    expect(page).not_to have_content "Price"
    expect(page).not_to have_content "Available budget"
    expect(page).not_to have_content "€"
    within("tr", text: "First selected") { expect(page).not_to have_content 200 }
    within("tr", text: "Second selected") { expect(page).not_to have_content 300 }
  end

  scenario "Does not raise error if budget (slug or id) is not found" do
    visit budget_results_path("wrong budget")

    within(".budgets-stats") do
      expect(page).to have_content "Participatory budget results"
    end

    visit budget_results_path(0)

    within(".budgets-stats") do
      expect(page).to have_content "Participatory budget results"
    end
  end

  scenario "Loads budget and heading by slug", :consul do
    visit budget_results_path(budget.slug, heading_id: heading.slug)

    expect(page).to have_selector("a.is-active", text: heading.name)

    within("#budget-investments-compatible") do
      expect(page).to have_content "First selected"
    end
  end

  scenario "Load first budget heading if not specified" do
    other_heading = create(:budget_heading, group: group)
    other_investment = create(:budget_investment, :winner, heading: other_heading)

    visit budget_results_path(budget)

    within("#budget-investments-compatible") do
      expect(page).to have_content "First selected"
      expect(page).not_to have_content other_investment.title
    end
  end

  scenario "If budget is in a phase different from finished results can't be accessed" do
    budget.update!(phase: (Budget::Phase::PHASE_KINDS - ["drafting", "finished"]).sample)
    visit budget_path(budget)
    expect(page).not_to have_link "See results"

    visit budget_results_path(budget, heading_id: heading)

    expect(page).to have_content "You do not have permission to carry out the action"
  end

  scenario "No incompatible investments" do
    Budget::Investment.incompatible.first.update!(incompatible: false, title: "Compatible investment")

    visit budget_path(budget)
    click_link "See results"

    expect(page).to have_content "First selected"
    expect(page).to have_content "Second selected"
    expect(page).to have_content "Compatible investment"
    expect(page).not_to have_content "Exceeding price"

    click_link "Show all"

    expect(page).to have_content "Exceeding price"
    expect(page).not_to have_content "Incompatibles"
  end
end
