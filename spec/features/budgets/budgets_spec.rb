require 'rails_helper'

feature 'Budgets' do

  scenario 'Index' do
    budgets = create_list(:budget, 3)
    visit budgets_path
    budgets.each {|budget| expect(page).to have_link(budget.name)}
  end

  scenario 'Show' do
    budget = create(:budget)
    group1 = create(:budget_group, budget: budget)
    group2 = create(:budget_group, budget: budget)

    visit budget_path(budget)

    budget.groups.each {|group| expect(page).to have_link(group.name)}
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