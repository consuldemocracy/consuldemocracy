require 'rails_helper'

feature 'Results' do

  let(:budget)  { create(:budget, phase: "finished") }
  let(:group)   { create(:budget_group, budget: budget) }
  let(:heading) { create(:budget_heading, group: group, price: 1000) }

  let!(:investment1) { create(:budget_investment, :selected, heading: heading, price: 200, ballot_lines_count: 900) }
  let!(:investment2) { create(:budget_investment, :selected, heading: heading, price: 300, ballot_lines_count: 800) }
  let!(:investment3) { create(:budget_investment, :incompatible, heading: heading, price: 500, ballot_lines_count: 700) }
  let!(:investment4) { create(:budget_investment, :selected, heading: heading, price: 600, ballot_lines_count: 600) }

  background do
    Budget::Result.new(budget, heading).calculate_winners
  end

  scenario "Diplays winner investments" do
    create(:budget_heading, group: group)

    visit budget_path(budget)
    click_link "See results"

    expect(page).to have_selector('a.is-active', text: budget.headings.first.name)

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

  scenario "Load first budget heading if not specified" do
    other_heading = create(:budget_heading, group: group)
    other_investment = create(:budget_investment, :winner, heading: other_heading)

    visit custom_budget_results_path(budget)

    within("#budget-investments-compatible") do
      expect(page).to have_content investment1.title
      expect(page).not_to have_content other_investment.title
    end
  end

  scenario "No incompatible investments", :js do
    investment3.incompatible = false
    investment3.save

    visit budget_path(budget)
    click_link "See results"

    expect(page).not_to have_content "Incompatibles"
  end

  context "Index" do

    scenario "Display links to finished budget results" do
      (Budget::Phase::PHASE_KINDS - ['finished']).each do |phase|
        budget = create(:budget, phase: phase)
        expect(page).to_not have_css("#budget_#{budget.id}_results", text: "See results")
      end

      finished_budget1 = create(:budget, phase: "finished")
      finished_budget2 = create(:budget, phase: "finished")
      finished_budget3 = create(:budget, phase: "finished")

      visit budgets_path

      expect(page).to have_css("#budget_#{finished_budget1.id}_results", text: "See results")
      expect(page).to have_css("#budget_#{finished_budget2.id}_results", text: "See results")
      expect(page).to have_css("#budget_#{finished_budget3.id}_results", text: "See results")
    end
  end

  context "Show" do

    it "is not accessible to normal users if phase is not 'finished'" do
      budget.update(phase: 'reviewing_ballots')

      visit budget_results_path(budget.id)
      expect(page).to have_content "You do not have permission to carry out the action "\
                                   "'read_results' on budget."
    end

    it "is accessible to normal users if phase is 'finished'" do
      budget.update(phase: 'finished')

      visit budget_results_path(budget.id)
      expect(page).to have_content "Results"
    end

    it "is accessible to administrators when budget has phase 'reviewing_ballots'" do
      budget.update(phase: 'reviewing_ballots')

      login_as(create(:administrator).user)

      visit budget_results_path(budget.id)
      expect(page).to have_content "Results"
    end

  end

end
