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
      expect(page).to have_link 'Help about participatory budgets'
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
                                  summary: 'This is the summary for drafting phase')

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
    expect(page).not_to have_content "30 Dec 2017 - 31 Dec 2017"
    expect(page).not_to have_content "This is the summary for reviewing phase"
    expect(page).not_to have_content "11 Jan 2018 - 20 Jan 2018"
    expect(page).not_to have_content "This is the summary for valuating phase"
    expect(page).not_to have_content "10 Feb 2018 - 20 Feb 2018"
    expect(page).not_to have_content "This is the summary for publishing_prices phase"
    expect(page).not_to have_content "21 Feb 2018 - 01 Mar 2018"
    expect(page).not_to have_content "This is the summary for reviewing_ballots phase"
    expect(page).not_to have_content "11 Mar 2018 - 20 Mar 2018'"

    expect(page).to have_content "This is the summary for accepting phase"
    expect(page).to have_content "01 Jan 2018 - 20 Jan 2018"
    expect(page).to have_content "This is the summary for selecting phase"
    expect(page).to have_content "21 Jan 2018 - 01 Mar 2018"
    expect(page).to have_content "This is the summary for balloting phase"
    expect(page).to have_content "02 Mar 2018 - 20 Mar 2018"
    expect(page).to have_content "This is the summary for finished phase"
    expect(page).to have_content "21 Mar 2018 - 29 Mar 2018"

    expect(page).to have_css(".phase.active", count: 1)
  end

  context "Advanced search" do

    context "Search by phase type" do

      scenario "Accepting Budget", :js do
        budget = create(:budget, :accepting)
        budget2 = create(:budget, :reviewing)
        visit budgets_path
        click_link "js-advanced-search-title"
        select('Accepting projects', from: 'advanced_search_budget_phase')
        click_button "Filter"
        within "#budgets" do
          expect(page).to have_content(budget.translated_phase)
          expect(page).to_not have_content(budget2.translated_phase)
        end
      end

      scenario "Reviewing Budget", :js do
        budget = create(:budget, :reviewing)
        budget2 = create(:budget, :accepting)
        visit budgets_path
        click_link "js-advanced-search-title"
        select('Reviewing projects', from: 'advanced_search_budget_phase')
        click_button "Filter"
        within "#budgets" do
          expect(page).to have_content(budget.translated_phase)
          expect(page).to_not have_content(budget2.translated_phase)
        end
      end

      scenario "Selecting Budget", :js do
        budget = create(:budget, :selecting)
        budget2 = create(:budget, :reviewing)
        visit budgets_path
        click_link "js-advanced-search-title"
        select('Selecting projects', from: 'advanced_search_budget_phase')
        click_button "Filter"
        within "#budgets" do
          expect(page).to have_content(budget.translated_phase)
          expect(page).to_not have_content(budget2.translated_phase)
        end
      end

      scenario "Valuating Budget", :js do
        budget = create(:budget, :valuating)
        budget2 = create(:budget, :reviewing)
        visit budgets_path
        click_link "js-advanced-search-title"
        select('Valuating projects', from: 'advanced_search_budget_phase')
        click_button "Filter"
        within "#budgets" do
          expect(page).to have_content(budget.translated_phase)
          expect(page).to_not have_content(budget2.translated_phase)
        end
      end

      scenario "Balloting Budget", :js do
        budget = create(:budget, :balloting)
        budget2 = create(:budget, :reviewing)
        visit budgets_path
        click_link "js-advanced-search-title"
        select('Balloting projects', from: 'advanced_search_budget_phase')
        click_button "Filter"
        within "#budgets" do
          expect(page).to have_content(budget.translated_phase)
          expect(page).to_not have_content(budget2.translated_phase)
        end
      end

      scenario "Reviewing Ballots", :js do
        budget = create(:budget, :reviewing_ballots)
        budget2 = create(:budget, :reviewing)
        visit budgets_path
        click_link "js-advanced-search-title"
        select('Reviewing Ballots', from: 'advanced_search_budget_phase')
        click_button "Filter"
        within "#budgets" do
          expect(page).to have_content(budget.translated_phase)
          expect(page).to_not have_content(budget2.translated_phase)
        end
      end

      scenario "Finished Ballots", :js do
        budget  = create(:budget, :finished)
        budget2 = create(:budget, :reviewing)
        visit budgets_path
        click_link "js-advanced-search-title"
        select('Finished budget', from: 'advanced_search_budget_phase')
        click_button "Filter"
        within "#budgets" do
          expect(page).to have_content(budget.translated_phase)
          expect(page).to_not have_content(budget2.translated_phase)
        end
      end
    end
  end

  context "Search by date" do

    context "Predefined date ranges" do

      scenario "Last day", :js do
        budget = create(:budget, :accepting, created_at: 1.day.ago)
        budget2 = create(:budget, :reviewing, created_at: 2.days.ago)
        visit budgets_path
        click_link "js-advanced-search-title"
        select "Last 24 hours", from: "js-advanced-search-date-min"
        click_button "Filter"
        within "#budgets" do
          expect(page).to have_content(budget.translated_phase)
          expect(page).to_not have_content(budget2.translated_phase)
        end
      end

      scenario "Search by multiple filters", :js do
        budget = create(:budget, :accepting, created_at: 1.day.ago)
        budget2 = create(:budget, :selecting, created_at: 2.days.ago)
        visit budgets_path
        click_link "js-advanced-search-title"
        select('Accepting projects', from: 'advanced_search_budget_phase')
        select "Last 24 hours", from: "js-advanced-search-date-min"
        click_button "Filter"
        within "#budgets" do
          expect(page).to have_content(budget.translated_phase)
          expect(page).to_not have_content(budget2.translated_phase)
        end
      end

      scenario "Maintain advanced search criteria", :js do
        visit budgets_path
        click_link "js-advanced-search-title"
        select('Accepting projects', from: 'advanced_search_budget_phase')
        select "Last 24 hours", from: "js-advanced-search-date-min"
        click_button "Filter"
        within "#js-advanced-search" do
          expect(page).to have_select('advanced_search[budget_phase]', selected: 'Accepting projects')
          expect(page).to have_select('advanced_search[date_min]', selected: 'Last 24 hours')
        end
      end

      scenario "Maintain custom date search criteria", :js do
        visit budgets_path
        click_link "js-advanced-search-title"
        select "Customized", from: "js-advanced-search-date-min"
        fill_in "advanced_search_date_min", with: 7.days.ago
        fill_in "advanced_search_date_max", with: 1.day.ago
        click_button "Filter"
        within "#js-advanced-search" do
          expect(page).to have_select('advanced_search[date_min]', selected: 'Customized')
          expect(page).to have_selector("input[name='advanced_search[date_min]'][value*='#{7.days.ago.strftime('%Y-%m-%d')}']")
          expect(page).to have_selector("input[name='advanced_search[date_max]'][value*='#{1.day.ago.strftime('%Y-%m-%d')}']")
        end
      end

    end
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
