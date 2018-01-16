require 'rails_helper'

feature 'Budgets' do

  let(:budget) { create(:budget) }
  let(:level_two_user) { create(:user, :level_two) }

  scenario 'Index' do
    budgets = create_list(:budget, 3)
    visit budgets_path
    expect(page).to have_content "Los presupuestos participativos en 2 minutos"
  end

  context 'Show' do

    scenario "List all groups" do
      group1 = create(:budget_group, budget: budget)
      group2 = create(:budget_group, budget: budget)

      visit budget_path(budget)

      budget.groups.each {|group| expect(page).to have_link(group.name)}
    end

    scenario "Links to unfeasible and selected if balloting or later" do
      budget = create(:budget, :selecting)
      group = create(:budget_group, budget: budget)

      visit budget_path(budget)

      expect(page).not_to have_link "See unfeasible investments"
      expect(page).not_to have_link "See investments not selected for balloting phase"

      click_link group.name

      expect(page).not_to have_link "See unfeasible investments"
      expect(page).not_to have_link "See investments not selected for balloting phase"

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

  context "In Drafting phase" do

    let(:admin) { create(:administrator).user }

    background do
      logout
      budget.update(phase: 'drafting')
    end

    context "Listed" do
      before { skip "At madrid we're not listing budgets" }

      scenario "Not listed to guest users at the public budgets list" do
        visit budgets_path

        expect(page).not_to have_content(budget.name)
      end

      scenario "Not listed to logged users at the public budgets list" do
        login_as(level_two_user)
        visit budgets_path

        expect(page).not_to have_content(budget.name)
      end

      scenario "Is listed to admins at the public budgets list" do
        login_as(admin)
        visit budgets_path

        expect(page).to have_content(budget.name)
      end
    end

    context "Shown" do
      scenario "Not accesible to guest users" do
        expect { visit budget_path(budget) }.to raise_error(ActionController::RoutingError)
      end

      scenario "Not accesible to logged users" do
        login_as(level_two_user)

        expect { visit budget_path(budget) }.to raise_error(ActionController::RoutingError)
      end

      scenario "Is accesible to admin users" do
        login_as(admin)
        visit budget_path(budget)

        expect(page.status_code).to eq(200)
      end
    end

  end

  context 'Accepting' do

    background do
      budget.update(phase: 'accepting')
    end

    context "Permissions" do

      scenario "Verified user" do
        login_as(level_two_user)

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
