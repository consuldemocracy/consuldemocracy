require 'rails_helper'

feature 'Budget Investments' do

  let(:author)  { create(:user, :level_two, username: 'Isabel') }
  let(:budget)  { create(:budget) }
  let(:group)   { create(:budget_group, budget: budget) }
  let(:heading) { create(:budget_heading, group: group) }

  scenario 'Index' do
    investments = [create(:budget_investment, heading: heading), create(:budget_investment, heading: heading), create(:budget_investment, :feasible, heading: heading)]
    unfeasible_investment = create(:budget_investment, :unfeasible, heading: heading)

    visit budget_investments_path(budget_id: budget.id)

    expect(page).to have_selector('#budget-investments .budget-investment', count: 3)
    investments.each do |investment|
      within('#budget-investments') do
        expect(page).to have_content investment.title
        expect(page).to have_css("a[href='#{budget_investment_path(budget_id: budget.id, id: investment.id)}']", text: investment.title)
        expect(page).to_not have_content(unfeasible_investment.title)
      end
    end
  end

  context("Search") do
    scenario 'Search by text' do
      investment1 = create(:budget_investment, heading: heading, title: "Get Schwifty")
      investment2 = create(:budget_investment, heading: heading, title: "Schwifty Hello")
      investment3 = create(:budget_investment, heading: heading, title: "Do not show me")

      visit budget_investments_path(budget_id: budget.id)

      within(".expanded #search_form") do
        fill_in "search", with: "Schwifty"
        click_button "Search"
      end

      within("#budget-investments") do
        expect(page).to have_css('.budget-investment', count: 2)

        expect(page).to have_content(investment1.title)
        expect(page).to have_content(investment2.title)
        expect(page).to_not have_content(investment3.title)
      end
    end
  end

  context("Filters") do
    scenario 'by unfeasibility' do
      investment1 = create(:budget_investment, :unfeasible, heading: heading, valuation_finished: true)
      investment2 = create(:budget_investment, :feasible, heading: heading)
      investment3 = create(:budget_investment, heading: heading)
      investment4 = create(:budget_investment, :feasible, heading: heading)

      visit budget_investments_path(budget_id: budget.id, unfeasible: 1)

      within("#budget-investments") do
        expect(page).to have_css('.budget-investment', count: 1)

        expect(page).to have_content(investment1.title)
        expect(page).to_not have_content(investment2.title)
        expect(page).to_not have_content(investment3.title)
        expect(page).to_not have_content(investment4.title)
      end
    end
  end

  context("Orders") do

    scenario "Default order is random" do
      per_page = Kaminari.config.default_per_page
      (per_page + 2).times { create(:budget_investment) }

      visit budget_investments_path(budget_id: budget.id)
      order = all(".budget-investment h3").collect {|i| i.text }

      visit budget_investments_path(budget_id: budget.id)
      new_order = eq(all(".budget-investment h3").collect {|i| i.text })

      expect(order).to_not eq(new_order)
    end

    scenario "Random order after another order" do
      per_page = Kaminari.config.default_per_page
      (per_page + 2).times { create(:budget_investment) }

      visit budget_investments_path(budget_id: budget.id)
      click_link "highest rated"
      click_link "random"

      order = all(".budget-investment h3").collect {|i| i.text }

      visit budget_investments_path(budget_id: budget.id)
      new_order = eq(all(".budget-investment h3").collect {|i| i.text })

      expect(order).to_not eq(new_order)
    end

    scenario 'Random order maintained with pagination', :js do
      per_page = Kaminari.config.default_per_page
      (per_page + 2).times { create(:budget_investment, heading: heading) }

      visit budget_investments_path(budget_id: budget.id)

      order = all(".budget-investment h3").collect {|i| i.text }

      click_link 'Next'
      expect(page).to have_content "You're on page 2"

      click_link 'Previous'
      expect(page).to have_content "You're on page 1"

      new_order = all(".budget-investment h3").collect {|i| i.text }
      expect(order).to eq(new_order)
    end

    scenario 'Proposals are ordered by confidence_score', :js do
      create(:budget_investment, heading: heading, title: 'Best proposal').update_column(:confidence_score, 10)
      create(:budget_investment, heading: heading, title: 'Worst proposal').update_column(:confidence_score, 2)
      create(:budget_investment, heading: heading, title: 'Medium proposal').update_column(:confidence_score, 5)

      visit budget_investments_path(budget_id: budget.id)
      click_link 'highest rated'
      expect(page).to have_selector('a.active', text: 'highest rated')

      within '#budget-investments' do
        expect('Best proposal').to appear_before('Medium proposal')
        expect('Medium proposal').to appear_before('Worst proposal')
      end

      expect(current_url).to include('order=confidence_score')
      expect(current_url).to include('page=1')
    end

  end

  xscenario 'Create with invisible_captcha honeypot field' do
    login_as(author)
    visit new_budget_investment_path(budget_id: budget.id)

    fill_in 'investment_title', with: 'I am a bot'
    fill_in 'investment_subtitle', with: 'This is the honeypot'
    fill_in 'investment_description', with: 'This is the description'
    select  'All city', from: 'investment_heading_id'
    check 'investment_terms_of_service'

    click_button 'Create'

    expect(page.status_code).to eq(200)
    expect(page.html).to be_empty
    expect(current_path).to eq(budget_investments_path(budget_id: budget.id))
  end

  xscenario 'Create spending proposal too fast' do
    allow(InvisibleCaptcha).to receive(:timestamp_threshold).and_return(Float::INFINITY)

    login_as(author)

    visit new_budget_investments_path(budget_id: budget.id)
    fill_in 'investment_title', with: 'I am a bot'
    fill_in 'investment_description', with: 'This is the description'
    select  'All city', from: 'investment_heading_id'
    check 'investment_terms_of_service'

    click_button 'Create'

    expect(page).to have_content 'Sorry, that was too quick! Please resubmit'
    expect(current_path).to eq(new_budget_investment_path(budget_id: budget.id))
  end

  xscenario 'Create notice' do
    login_as(author)

    visit new_budget_investment_path(budget_id: budget.id)
    fill_in 'investment_title', with: 'Build a skyscraper'
    fill_in 'investment_description', with: 'I want to live in a high tower over the clouds'
    fill_in 'investment_external_url', with: 'http://http://skyscraperpage.com/'
    select  'All city', from: 'investment_heading_id'
    check 'investment_terms_of_service'

    click_button 'Create'

    expect(page).to_not have_content 'Investment project created successfully'
    expect(page).to have_content '1 error'

    within "#notice" do
      click_link 'My activity'
    end

    expect(page).to have_content 'Investment project created successfully'
  end

  xscenario 'Errors on create' do
    login_as(author)

    visit new_budget_investment_path(budget_id: budget.id)
    click_button 'Create'
    expect(page).to have_content error_message
  end

  scenario "Show" do
    user = create(:user)
    login_as(user)

    investment = create(:budget_investment, heading: heading)

    visit budget_investment_path(budget_id: budget.id, id: investment.id)

    expect(page).to have_content(investment.title)
    expect(page).to have_content(investment.description)
    expect(page).to have_content(investment.author.name)
    expect(page).to have_content(investment.heading.name)
    within("#investment_code") do
      expect(page).to have_content(investment.id)
    end
  end

  scenario "Show (feasible spending proposal)" do
    user = create(:user)
    login_as(user)

    investment = create(:budget_investment,
                        :feasible,
                        :finished,
                        heading: heading,
                        price: 16,
                        price_explanation: 'Every wheel is 4 euros, so total is 16')

    visit budget_investment_path(budget_id: budget.id, id: investment.id)

    expect(page).to have_content("Price explanation")
    expect(page).to have_content(investment.price_explanation)
  end

  scenario "Show (unfeasible spending proposal)" do
    user = create(:user)
    login_as(user)

    investment = create(:budget_investment,
                        :unfeasible,
                        :finished,
                        heading: heading,
                        unfeasibility_explanation: 'Local government is not competent in this matter')

    visit budget_investment_path(budget_id: budget.id, id: investment.id)

    expect(page).to have_content("Unfeasibility explanation")
    expect(page).to have_content(investment.unfeasibility_explanation)
  end

  context "Destroy" do

    xscenario "Admin cannot destroy spending proposals" do
      admin = create(:administrator)
      user = create(:user, :level_two)
      investment = create(:budget_investment, heading: heading, author: user)

      login_as(admin.user)
      visit user_path(user)

      within("#investment_#{investment.id}") do
        expect(page).to_not have_link "Delete"
      end
    end

  end

  context "Badge" do

    scenario "Spending proposal created by a User" do
      user = create(:user)
      user_investment = create(:budget_investment, heading: heading)

      visit budget_investment_path(budget_id: budget.id, id: user_investment.id)
      expect(page).to_not have_css "is-forum"

      visit budget_investments_path(budget_id: budget.id, id: user_investment.id)
      within "#budget_investment_#{user_investment.id}" do
        expect(page).to_not have_css "is-forum"
      end
    end

  end

  context "Phase 3 - Final Voting" do

    background do
      budget.update(phase: "balloting")
    end

    xscenario "Index" do
      user = create(:user, :level_two)
      sp1 = create(:budget_investment, :feasible, :finished, heading: heading, price: 10000)
      sp2 = create(:budget_investment, :feasible, :finished, heading: heading, price: 20000)

      login_as(user)
      visit root_path

      first(:link, "Participatory budgeting").click
      click_link budget.name
      click_link "No Heading"

      within("#budget_investment_#{sp1.id}") do
        expect(page).to have_content sp1.title
        expect(page).to have_content "€10,000"
      end

      within("#budget_investment_#{sp2.id}") do
        expect(page).to have_content sp2.title
        expect(page).to have_content "€20,000"
      end
    end

    xscenario 'Order by cost (only in phase3)' do
      create(:budget_investment, :feasible, :finished, heading: heading, title: 'Build a nice house',  price:  1000).update_column(:confidence_score, 10)
      create(:budget_investment, :feasible, :finished, heading: heading, title: 'Build an ugly house', price:  1000).update_column(:confidence_score, 5)
      create(:budget_investment, :feasible, :finished, heading: heading, title: 'Build a skyscraper',  price: 20000)

      visit budget_investments_path(budget_id: budget.id)

      click_link 'by price'
      expect(page).to have_selector('a.active', text: 'by price')

      within '#budget-investments' do
        expect('Build a skyscraper').to appear_before('Build a nice house')
        expect('Build a nice house').to appear_before('Build an ugly house')
      end

      expect(current_url).to include('order=price')
      expect(current_url).to include('page=1')
    end

    scenario "Show" do
      user = create(:user, :level_two)
      sp1 = create(:budget_investment, :feasible, :finished, heading: heading, price: 10000)

      login_as(user)
      visit root_path

      first(:link, "Participatory budgeting").click
      click_link budget.name
      click_link "No Heading"

      click_link sp1.title

      expect(page).to have_content "€10,000"
    end

    xscenario "Confirm", :js do
      user = create(:user, :level_two)

      carabanchel = create(:geozone, name: "Carabanchel")
      new_york    = create(:geozone, name: "New York")

      carabanchel_heading = create(:budget_heading, heading: heading, geozone: carabanchel, name: carabanchel.name)
      new_york_heading     = create(:budget_heading, heading: heading, geozone: new_york, name: new_york.name)

      sp1 = create(:budget_investment, :feasible, :finished, price:      1, heading: nil)
      sp2 = create(:budget_investment, :feasible, :finished, price:     10, heading: nil)
      sp3 = create(:budget_investment, :feasible, :finished, price:    100, heading: nil)
      sp4 = create(:budget_investment, :feasible, :finished, price:   1000, heading: carabanchel_heading)
      sp5 = create(:budget_investment, :feasible, :finished, price:  10000, heading: carabanchel_heading)
      sp6 = create(:budget_investment, :feasible, :finished, price: 100000, heading: new_york_heading)

      login_as(user)
      visit root_path

      first(:link, "Participatory budgeting").click
      click_link budget.name
      click_link "No Heading"

      add_to_ballot(sp1)
      add_to_ballot(sp2)

      first(:link, "Participatory budgeting").click

      click_link budget.name
      click_link carabanchel.name

      add_to_ballot(sp4)
      add_to_ballot(sp5)

      click_link "Check my ballot"

      expect(page).to have_content "You can change your vote at any time until the close of this phase"

      within("#city_wide") do
        expect(page).to have_content sp1.title
        expect(page).to have_content sp1.price

        expect(page).to have_content sp2.title
        expect(page).to have_content sp2.price

        expect(page).to_not have_content sp3.title
        expect(page).to_not have_content sp3.price
      end

      within("#district_wide") do
        expect(page).to have_content sp4.title
        expect(page).to have_content "$1,000"

        expect(page).to have_content sp5.title
        expect(page).to have_content "$10,000"

        expect(page).to_not have_content sp6.title
        expect(page).to_not have_content "$100,000"
      end
    end

  end

end
