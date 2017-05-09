require 'rails_helper'

feature 'Budgets' do

  scenario 'Index' do
    budgets = create_list(:budget, 3)
    visit budgets_path
    budgets.each {|budget| expect(page).to have_link(budget.name)}
  end

  context 'Show' do

    scenario "List all groups" do
      budget = create(:budget)
      group1 = create(:budget_group, budget: budget)
      group2 = create(:budget_group, budget: budget)

      visit budget_path(budget)

      budget.groups.each {|group| expect(page).to have_link(group.name)}
    end

    scenario "Links to unfeasible and selected if balloting or later" do
      budget = create(:budget, :selecting)
      group = create(:budget_group, budget: budget)

      visit budget_path(budget)

      expect(page).to_not have_link "See unfeasible investments"
      expect(page).to_not have_link "See investments not selected for balloting phase"

      click_link group.name

      expect(page).to_not have_link "See unfeasible investments"
      expect(page).to_not have_link "See investments not selected for balloting phase"

      budget.update(phase: :balloting)

      visit budget_path(budget)

      expect(page).to have_link "See unfeasible investments"
      expect(page).to have_link "See investments not selected for balloting phase"

      click_link group.name

      expect(page).to have_link "See unfeasible investments"
      expect(page).to have_link "See investments not selected for balloting phase"

      budget.update(phase: :finished)

      visit budget_path(budget)

      expect(page).to have_link "See unfeasible investments"
      expect(page).to have_link "See investments not selected for balloting phase"

      click_link group.name

      expect(page).to have_link "See unfeasible investments"
      expect(page).to have_link "See investments not selected for balloting phase"
    end

  end

  context 'Accepting' do

    let(:budget) { create(:budget) }

    background do
      budget.update(phase: 'accepting')
    end

    context "Permissions" do

      scenario "Verified user" do
        user = create(:user, :level_two)
        login_as(user)

        visit budget_path(budget)

        expect(page).to have_link "Create budget investment"
      end

      scenario "Unverified user" do
        user = create(:user)
        login_as(user)

        visit budget_path(budget)

        expect(page).to have_content "To create a new budget investment verify your account."
      end

      scenario "user not logged in" do
        visit budget_path(budget)

        expect(page).to have_content "To create a new budget investment you must sign in or sign up."
      end

    end
  end
end