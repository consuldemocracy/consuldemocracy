require 'rails_helper'

feature 'Budget Investments' do

  background do
    login_as_manager
    @budget = create(:budget, phase: 'selecting', name: "2033")
    @group = create(:budget_group, budget: @budget, name: 'Whole city')
    @heading = create(:budget_heading, group: @group, name: "Health")
  end


  scenario "Listing - admins can see budgets in accepting, reviewing and selecting phases" do
    accepting_budget = create(:budget, phase: "accepting")
    reviewing_budget = create(:budget, phase: "reviewing")
    selecting_budget = create(:budget, phase: "selecting")
    valuating_budget = create(:budget, phase: "valuating")
    balloting_budget = create(:budget, phase: "balloting")
    reviewing_ballots_budget = create(:budget, phase: "reviewing_ballots")
    finished = create(:budget, phase: "finished")

    visit root_path
    click_link('Sign out', match: :first)

    admin = create(:administrator)
    login_as(admin.user)

    user = create(:user, :level_two)
    login_managed_user(user)
    visit management_sign_in_path

    click_link "Create budget investment"

    expect(page).to have_content(accepting_budget.name)
    expect(page).to have_content(reviewing_budget.name)
    expect(page).to have_content(selecting_budget.name)

    expect(page).not_to have_content(valuating_budget.name)
    expect(page).not_to have_content(balloting_budget.name)
    expect(page).not_to have_content(reviewing_ballots_budget.name)
    expect(page).not_to have_content(finished.name)
  end

end
