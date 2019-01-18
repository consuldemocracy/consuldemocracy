require 'rails_helper'

feature 'Budget Investments' do

  background do
    login_as_manager
    @budget = create(:budget, phase: 'selecting', name: "2033")
    @group = create(:budget_group, budget: @budget, name: 'Whole city')
    @heading = create(:budget_heading, group: @group, name: "Health")
  end

  context "Create" do
    before { @budget.update(phase: 'accepting') }

    scenario 'Creating budget investments on behalf of someone, selecting a budget' do
      user = create(:user, :level_two)

      login_managed_user(user)

      click_link "Create budget investment"
      within "#budget_#{@budget.id}" do
        click_link "Create budget investment"
      end

      within(".account-info") do
        expect(page).to have_content "Identified as"
        expect(page).to have_content user.username
        expect(page).to have_content user.email
        expect(page).to have_content user.document_number
      end

      select "Health", from: 'budget_investment_heading_id'
      fill_in 'budget_investment_title', with: 'Build a park in my neighborhood'
      fill_in 'budget_investment_description', with: 'There is no parks here...'
      fill_in 'budget_investment_location', with: 'City center'
      fill_in 'budget_investment_organization_name', with: 'T.I.A.'
      fill_in 'budget_investment_tag_list', with: 'green'

      click_button 'Create Investment'

      expect(page).to have_content 'Investment created successfully.'

      expect(page).to have_content 'Health'
      expect(page).to have_content 'Build a park in my neighborhood'
      expect(page).to have_content 'There is no parks here...'
      expect(page).to have_content 'City center'
      expect(page).to have_content 'T.I.A.'
      expect(page).to have_content 'green'
      expect(page).to have_content user.name
      expect(page).to have_content I18n.l(@budget.created_at.to_date)
    end

    scenario "Should not allow unverified users to create budget investments" do
      user = create(:user)
      login_managed_user(user)

      click_link "Create budget investment"

      expect(page).to have_content "User is not verified"
    end
  end

  context "Searching" do

    scenario "by title" do
      budget_investment1 = create(:budget_investment, budget: @budget, title: "Show me what you got")
      budget_investment2 = create(:budget_investment, budget: @budget, title: "Get Schwifty")

      user = create(:user, :level_two)
      login_managed_user(user)

      click_link "Support budget investments"
      expect(page).to have_content(@budget.name)
      within "#budget_#{@budget.id}" do
        click_link "Support budget investments"
      end

      fill_in "search", with: "what you got"
      click_button "Search"

      within("#budget-investments") do
        expect(page).to have_css('.budget-investment', count: 1)
        expect(page).to have_content(budget_investment1.title)
        expect(page).not_to have_content(budget_investment2.title)
        expect(page).to have_css("a[href='#{management_budget_investment_path(@budget, budget_investment1)}']",
                                 text: budget_investment1.title)
      end
    end

    scenario "by heading" do
      budget_investment1 = create(:budget_investment, budget: @budget, title: "Hey ho",
                                                      heading: create(:budget_heading, name: "District 9"))
      budget_investment2 = create(:budget_investment, budget: @budget, title: "Let's go",
                                                      heading: create(:budget_heading, name: "Area 52"))

      user = create(:user, :level_two)
      login_managed_user(user)

      click_link "Support budget investments"
      expect(page).to have_content(@budget.name)
      within "#budget_#{@budget.id}" do
        click_link "Support budget investments"
      end

      fill_in "search", with: "Area 52"
      click_button "Search"

      within("#budget-investments") do
        expect(page).to have_css('.budget-investment', count: 1)
        expect(page).not_to have_content(budget_investment1.title)
        expect(page).to have_content(budget_investment2.title)
        expect(page).to have_css("a[href='#{management_budget_investment_path(@budget, budget_investment2)}']",
                                 text: budget_investment2.title)
      end
    end
  end

  scenario "Listing" do
    budget_investment1 = create(:budget_investment, budget: @budget, title: "Show me what you got")
    budget_investment2 = create(:budget_investment, budget: @budget, title: "Get Schwifty")

    user = create(:user, :level_two)
    login_managed_user(user)

    click_link "Support budget investments"
    expect(page).to have_content(@budget.name)
    within "#budget_#{@budget.id}" do
      click_link "Support budget investments"
    end

    within(".account-info") do
      expect(page).to have_content "Identified as"
      expect(page).to have_content user.username
      expect(page).to have_content user.email
      expect(page).to have_content user.document_number
    end

    within("#budget-investments") do
      expect(page).to have_css('.budget-investment', count: 2)
      expect(page).to have_css("a[href='#{management_budget_investment_path(@budget, budget_investment1)}']",
                               text: budget_investment1.title)
      expect(page).to have_css("a[href='#{management_budget_investment_path(@budget, budget_investment2)}']",
                               text: budget_investment2.title)
    end
  end

  scenario "Listing - managers can see budgets in accepting phase" do
    accepting_budget = create(:budget, phase: "accepting")
    reviewing_budget = create(:budget, phase: "reviewing")
    selecting_budget = create(:budget, phase: "selecting")
    valuating_budget = create(:budget, phase: "valuating")
    balloting_budget = create(:budget, phase: "balloting")
    reviewing_ballots_budget = create(:budget, phase: "reviewing_ballots")
    finished = create(:budget, phase: "finished")

    user = create(:user, :level_two)
    login_managed_user(user)

    click_link "Create budget investment"

    expect(page).to have_content(accepting_budget.name)

    expect(page).not_to have_content(reviewing_budget.name)
    expect(page).not_to have_content(selecting_budget.name)
    expect(page).not_to have_content(valuating_budget.name)
    expect(page).not_to have_content(balloting_budget.name)
    expect(page).not_to have_content(reviewing_ballots_budget.name)
    expect(page).not_to have_content(finished.name)
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
    click_link "Sign out"

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

  context "Supporting" do

    scenario 'Supporting budget investments on behalf of someone in index view', :js do
      budget_investment = create(:budget_investment, budget: @budget, heading: @heading)

      user = create(:user, :level_two)
      login_managed_user(user)

      click_link "Support budget investments"
      expect(page).to have_content(@budget.name)
      within "#budget_#{@budget.id}" do
        click_link "Support budget investments"
      end
      expect(page).to have_content(budget_investment.title)

      within("#budget-investments") do
        accept_confirm { find('.js-in-favor a').click }

        expect(page).to have_content "1 support"
        expect(page).to have_content "You have already supported this investment project. Share it!"
      end
    end

    # This test passes ok locally but fails on the last two lines in Travis
    xscenario 'Supporting budget investments on behalf of someone in show view', :js do
      budget_investment = create(:budget_investment, budget: @budget)

      user = create(:user, :level_two)
      login_managed_user(user)

      click_link "Support budget investments"
      expect(page).to have_content(@budget.name)
      within "#budget_#{@budget.id}" do
        click_link "Support budget investments"
      end

      within("#budget-investments") do
        click_link budget_investment.title
      end

      find('.js-in-favor a').click
      expect(page).to have_content "1 support"
      expect(page).to have_content "You have already supported this. Share it!"
    end

    scenario "Should not allow unverified users to vote proposals" do
      budget_investment = create(:budget_investment, budget: @budget)

      user = create(:user)
      login_managed_user(user)

      click_link "Support budget investments"

      expect(page).to have_content "User is not verified"
    end
  end

  context "Printing" do

    scenario 'Printing budget investments' do
      16.times { create(:budget_investment, budget: @budget, heading: @heading) }

      click_link "Print budget investments"

      expect(page).to have_content(@budget.name)
      within "#budget_#{@budget.id}" do
        click_link "Print budget investments"
      end

      expect(page).to have_css('.budget-investment', count: 15)
      expect(page).to have_css("a[href='javascript:window.print();']", text: 'Print')
    end

    scenario "Filtering budget investments by heading to be printed", :js do
      district_9 = create(:budget_heading, group: @group, name: "District Nine")
      another_heading = create(:budget_heading, group: @group)
      low_investment = create(:budget_investment, budget: @budget, title: 'Nuke district 9', heading: district_9, cached_votes_up: 1)
      mid_investment = create(:budget_investment, budget: @budget, title: 'Change district 9', heading: district_9, cached_votes_up: 10)
      top_investment = create(:budget_investment, budget: @budget, title: 'Destroy district 9', heading: district_9, cached_votes_up: 100)
      unvoted_investment = create(:budget_investment, budget: @budget, heading: another_heading, title: 'Add new districts to the city')

      user = create(:user, :level_two)
      login_managed_user(user)

      click_link "Print budget investments"

      expect(page).to have_content(@budget.name)
      within "#budget_#{@budget.id}" do
        click_link "Print budget investments"
      end

      within '#budget-investments' do
        expect(page).to have_content(unvoted_investment.title)
        expect(page).to have_content(mid_investment.title)
        expect(page).to have_content(top_investment.title)
        expect(page).to have_content(low_investment.title)
      end

      select 'Whole city: District Nine', from: 'heading_id'
      click_button("Search")

      within '#budget-investments' do
        expect(page).not_to have_content(unvoted_investment.title)
        expect(top_investment.title).to appear_before(mid_investment.title)
        expect(mid_investment.title).to appear_before(low_investment.title)
      end
    end

  end

end
