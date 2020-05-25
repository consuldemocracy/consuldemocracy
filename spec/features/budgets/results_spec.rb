require "rails_helper"

describe "Results" do

  let(:budget)  { create(:budget, :finished) }
  let(:group)   { create(:budget_group, budget: budget) }
  let(:heading) { create(:budget_heading, group: group, price: 1000) }

  let!(:investment1) { create(:budget_investment, :selected, heading: heading, price: 200, ballot_lines_count: 900) }
  let!(:investment2) { create(:budget_investment, :selected, heading: heading, price: 300, ballot_lines_count: 800) }
  let!(:investment3) { create(:budget_investment, :incompatible, heading: heading, price: 500, ballot_lines_count: 700) }
  let!(:investment4) { create(:budget_investment, :selected, heading: heading, price: 600, ballot_lines_count: 600) }

  before do
    Budget::Result.new(budget, heading).calculate_winners
  end

  scenario "No links to budget results with results disabled" do
    budget.update(results_enabled: false)

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

    expect(page).to have_selector("a.is-active", text: budget.headings.first.name)

    within("#budget-investments-compatible") do
      expect(page).to have_content investment1.title
      expect(page).to have_content investment2.title
      expect(page).not_to have_content investment3.title
      expect(page).not_to have_content investment4.title

      expect(investment1.title).to appear_before(investment2.title)
    end
  end

  scenario "Show non winner & incomaptible investments", :js do
    visit budget_path(budget)
    click_link "See results"
    click_link "Show all"

    within("#budget-investments-compatible") do
      expect(page).to have_content investment1.title
      expect(page).to have_content investment2.title
      expect(page).to have_content investment4.title

      expect(investment1.title).to appear_before(investment2.title)
      expect(investment2.title).to appear_before(investment4.title)
    end

    within("#budget-investments-incompatible") do
      expect(page).to have_content investment3.title
    end
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

  scenario "Loads budget and heading by slug" do
    visit budget_results_path(budget.slug, heading.slug)

    expect(page).to have_selector("a.is-active", text: heading.name)

    within("#budget-investments-compatible") do
      expect(page).to have_content investment1.title
    end
  end

  scenario "Load first budget heading if not specified" do
    other_heading = create(:budget_heading, group: group)
    other_investment = create(:budget_investment, :winner, heading: other_heading)

    visit budget_results_path(budget)

    within("#budget-investments-compatible") do
      expect(page).to have_content investment1.title
      expect(page).not_to have_content other_investment.title
    end
  end

  scenario "If budget is in a phase different from finished results can't be accessed" do
    budget.update(phase: (Budget::Phase::PHASE_KINDS - ["drafting", "finished"]).sample)
    visit budget_path(budget)
    expect(page).not_to have_link "See results"

    visit budget_results_path(budget, heading_id: budget.headings.first)
    expect(page).to have_content "You do not have permission to carry out the action"
  end

  scenario "No incompatible investments", :js do
    investment3.incompatible = false
    investment3.save

    visit budget_path(budget)
    click_link "See results"

    expect(page).not_to have_content "Incompatibles"
  end

end
