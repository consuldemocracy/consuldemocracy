require 'rails_helper'

feature 'Budgets' do

  let(:budget) { create(:budget) }
  let(:level_two_user) { create(:user, :level_two) }

  scenario 'Index' do
    budgets = create_list(:budget, 3)
    last_budget = budgets.last
    group1 = create(:budget_group, budget: last_budget)
    group2 = create(:budget_group, budget: last_budget)

    heading1 = create(:budget_heading, group: group1)
    heading2 = create(:budget_heading, group: group2)

    visit budgets_path

    within("#budget_heading") do
      expect(page).to have_content(last_budget.name)
      expect(page).to have_content(last_budget.description)
      expect(page).to have_content("Actual phase")
      expect(page).to have_content("Accepting projects")
      expect(page).to have_link 'Help with participatory budgets'
      expect(page).to have_link 'See all phases'
    end

    last_budget.update_attributes(phase: 'publishing_prices')
    visit budgets_path

    within("#budget_heading") do
      expect(page).to have_content("Actual phase")
    end

    within('#budget_info') do
      expect(page).to have_content group1.name
      expect(page).to have_content group2.name
      expect(page).to have_content heading1.name
      expect(page).to have_content last_budget.formatted_heading_price(heading1)
      expect(page).to have_content heading2.name
      expect(page).to have_content last_budget.formatted_heading_price(heading2)

      expect(page).to have_content budgets.first.name
      expect(page).to have_content budgets[2].name
    end
  end

  scenario 'Index shows only published phases' do

    budget.update(phase: :finished)

    budget.phases.drafting.update(starts_at: '30-12-2017', ends_at: '31-12-2017', enabled: true,
                                  description: 'Description of drafting phase',
                                  summary: '<p>This is the summary for drafting phase</p>')

    budget.phases.accepting.update(starts_at: '01-01-2018', ends_at: '10-01-2018', enabled: true,
                                   description: 'Description of accepting phase',
                                   summary: 'This is the summary for accepting phase')

    budget.phases.reviewing.update(starts_at: '11-01-2018', ends_at: '20-01-2018', enabled: false,
                                   description: 'Description of reviewing phase',
                                   summary: 'This is the summary for reviewing phase')

    budget.phases.selecting.update(starts_at: '21-01-2018', ends_at: '01-02-2018', enabled: true,
                                   description: 'Description of selecting phase',
                                   summary: 'This is the summary for selecting phase')

    budget.phases.valuating.update(starts_at: '10-02-2018', ends_at: '20-02-2018', enabled: false,
                                   description: 'Description of valuating phase',
                                   summary: 'This is the summary for valuating phase')

    budget.phases.publishing_prices.update(starts_at: '21-02-2018', ends_at: '01-03-2018', enabled: false,
                                           description: 'Description of publishing prices phase',
                                           summary: 'This is the summary for publishing_prices phase')

    budget.phases.balloting.update(starts_at: '02-03-2018', ends_at: '10-03-2018', enabled: true,
                                   description: 'Description of balloting phase',
                                   summary: 'This is the summary for balloting phase')

    budget.phases.reviewing_ballots.update(starts_at: '11-03-2018', ends_at: '20-03-2018', enabled: false,
                                           description: 'Description of reviewing ballots phase',
                                           summary: 'This is the summary for reviewing_ballots phase')

    budget.phases.finished.update(starts_at: '21-03-2018', ends_at: '30-03-2018', enabled: true,
                                  description: 'Description of finished phase',
                                  summary: 'This is the summary for finished phase')

    visit budgets_path

    expect(page).not_to have_content "This is the summary for drafting phase"
    expect(page).not_to have_content "December 30, 2017 - December 31, 2017"
    expect(page).not_to have_content "This is the summary for reviewing phase"
    expect(page).not_to have_content "January 11, 2018 - January 20, 2018"
    expect(page).not_to have_content "This is the summary for valuating phase"
    expect(page).not_to have_content "February 10, 2018 - February 20, 2018"
    expect(page).not_to have_content "This is the summary for publishing_prices phase"
    expect(page).not_to have_content "February 21, 2018 - March 01, 2018"
    expect(page).not_to have_content "This is the summary for reviewing_ballots phase"
    expect(page).not_to have_content "March 11, 2018 - March 20, 2018'"

    expect(page).to have_content "This is the summary for accepting phase"
    expect(page).to have_content "January 01, 2018 - January 20, 2018"
    expect(page).to have_content "This is the summary for selecting phase"
    expect(page).to have_content "January 21, 2018 - March 01, 2018"
    expect(page).to have_content "This is the summary for balloting phase"
    expect(page).to have_content "March 02, 2018 - March 20, 2018"
    expect(page).to have_content "This is the summary for finished phase"
    expect(page).to have_content "March 21, 2018 - March 29, 2018"

    expect(page).to have_css(".phase.active", count: 1)
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
      create(:budget)
    end

    context "Listed" do
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
        expect(page).to have_link "Create a budget investment"

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
