require 'rails_helper'

feature 'Spending proposals' do

  let(:author) { create(:user, :level_two, username: 'Isabel') }

  scenario 'Index' do
    spending_proposals = [create(:spending_proposal), create(:spending_proposal), create(:spending_proposal, feasible: true)]
    unfeasible_spending_proposal = create(:spending_proposal, feasible: false)

    visit spending_proposals_path

    expect(page).to have_selector('#investment-projects .investment-project', count: 3)
    spending_proposals.each do |spending_proposal|
      within('#investment-projects') do
        expect(page).to have_content spending_proposal.title
        expect(page).to have_css("a[href='#{spending_proposal_path(spending_proposal)}']", text: spending_proposal.title)
        expect(page).to_not have_content(unfeasible_spending_proposal.title)
      end
    end
  end

  context("Search") do
    scenario 'Search by text' do
      spending_proposal1 = create(:spending_proposal, title: "Get Schwifty")
      spending_proposal2 = create(:spending_proposal, title: "Schwifty Hello")
      spending_proposal3 = create(:spending_proposal, title: "Do not show me")

      visit spending_proposals_path

      within(".expanded #search_form") do
        fill_in "search", with: "Schwifty"
        click_button "Search"
      end

      within("#investment-projects") do
        expect(page).to have_css('.investment-project', count: 2)

        expect(page).to have_content(spending_proposal1.title)
        expect(page).to have_content(spending_proposal2.title)
        expect(page).to_not have_content(spending_proposal3.title)
      end
    end
  end

  context("Filters") do
    scenario 'by unfeasibility' do
      geozone1 = create(:geozone)
      spending_proposal1 = create(:spending_proposal, feasible: false, valuation_finished: true)
      spending_proposal2 = create(:spending_proposal, feasible: true)
      spending_proposal3 = create(:spending_proposal)
      spending_proposal4 = create(:spending_proposal, feasible: false)

      visit spending_proposals_path(unfeasible: 1)

      within("#investment-projects") do
        expect(page).to have_css('.investment-project', count: 1)

        expect(page).to have_content(spending_proposal1.title)
        expect(page).to_not have_content(spending_proposal2.title)
        expect(page).to_not have_content(spending_proposal3.title)
        expect(page).to_not have_content(spending_proposal4.title)
      end
    end
  end

  context("Orders") do

    scenario "Default order is random" do
      per_page = Kaminari.config.default_per_page
      (per_page + 2).times { create(:spending_proposal) }

      visit spending_proposals_path
      order = all(".investment-project h3").collect {|i| i.text }

      visit spending_proposals_path
      new_order = eq(all(".investment-project h3").collect {|i| i.text })

      expect(order).to_not eq(new_order)
    end

    scenario "Random order after another order" do
      per_page = Kaminari.config.default_per_page
      (per_page + 2).times { create(:spending_proposal) }

      visit spending_proposals_path
      click_link "highest rated"
      click_link "random"

      order = all(".investment-project h3").collect {|i| i.text }

      visit spending_proposals_path
      new_order = eq(all(".investment-project h3").collect {|i| i.text })

      expect(order).to_not eq(new_order)
    end


    scenario 'Random order maintained with pagination', :js do
      per_page = Kaminari.config.default_per_page
      (per_page + 2).times { create(:spending_proposal) }

      visit spending_proposals_path

      order = all(".investment-project h3").collect {|i| i.text }

      click_link 'Next'
      expect(page).to have_content "You're on page 2"

      click_link 'Previous'
      expect(page).to have_content "You're on page 1"

      new_order = all(".investment-project h3").collect {|i| i.text }
      expect(order).to eq(new_order)
    end

    scenario 'Proposals are ordered by confidence_score', :js do
      create(:spending_proposal, title: 'Best proposal').update_column(:confidence_score, 10)
      create(:spending_proposal, title: 'Worst proposal').update_column(:confidence_score, 2)
      create(:spending_proposal, title: 'Medium proposal').update_column(:confidence_score, 5)

      visit spending_proposals_path
      click_link 'highest rated'
      expect(page).to have_selector('a.active', text: 'highest rated')

      within '#investment-projects' do
        expect('Best proposal').to appear_before('Medium proposal')
        expect('Medium proposal').to appear_before('Worst proposal')
      end

      expect(current_url).to include('order=confidence_score')
      expect(current_url).to include('page=1')
    end

  end

  xscenario 'Create with invisible_captcha honeypot field' do
    login_as(author)

    visit new_spending_proposal_path
    fill_in 'spending_proposal_title', with: 'I am a bot'
    fill_in 'spending_proposal_subtitle', with: 'This is the honeypot'
    fill_in 'spending_proposal_description', with: 'This is the description'
    select  'All city', from: 'spending_proposal_geozone_id'
    check 'spending_proposal_terms_of_service'

    click_button 'Create'

    expect(page.status_code).to eq(200)
    expect(page.html).to be_empty
    expect(current_path).to eq(spending_proposals_path)
  end

  xscenario 'Create spending proposal too fast' do
    allow(InvisibleCaptcha).to receive(:timestamp_threshold).and_return(Float::INFINITY)

    login_as(author)

    visit new_spending_proposal_path
    fill_in 'spending_proposal_title', with: 'I am a bot'
    fill_in 'spending_proposal_description', with: 'This is the description'
    select  'All city', from: 'spending_proposal_geozone_id'
    check 'spending_proposal_terms_of_service'

    click_button 'Create'

    expect(page).to have_content 'Sorry, that was too quick! Please resubmit'
    expect(current_path).to eq(new_spending_proposal_path)
  end

  xscenario 'Create notice' do
    login_as(author)

    visit new_spending_proposal_path
    fill_in 'spending_proposal_title', with: 'Build a skyscraper'
    fill_in 'spending_proposal_description', with: 'I want to live in a high tower over the clouds'
    fill_in 'spending_proposal_external_url', with: 'http://http://skyscraperpage.com/'
    fill_in 'spending_proposal_association_name', with: 'People of the neighbourhood'
    select  'All city', from: 'spending_proposal_geozone_id'
    check 'spending_proposal_terms_of_service'

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

    visit new_spending_proposal_path
    click_button 'Create'
    expect(page).to have_content error_message
  end

  scenario "Show" do
    user = create(:user)
    login_as(user)

    spending_proposal = create(:spending_proposal,
                                geozone: create(:geozone),
                                association_name: 'People of the neighbourhood')

    visit spending_proposal_path(spending_proposal)

    expect(page).to have_content(spending_proposal.title)
    expect(page).to have_content(spending_proposal.description)
    expect(page).to have_content(spending_proposal.author.name)
    expect(page).to have_content(spending_proposal.association_name)
    expect(page).to have_content(spending_proposal.geozone.name)
    within("#spending_proposal_code") do
      expect(page).to have_content(spending_proposal.id)
    end
  end

  scenario "Show (feasible spending proposal)" do
    user = create(:user)
    login_as(user)

    spending_proposal = create(:spending_proposal,
                                valuation_finished: true,
                                feasible: true,
                                price: 16,
                                price_explanation: 'Every wheel is 4 euros, so total is 16')

    visit spending_proposal_path(spending_proposal)

    expect(page).to have_content("Price explanation")
    expect(page).to have_content(spending_proposal.price_explanation)
  end

  scenario "Show (unfeasible spending proposal)" do
    user = create(:user)
    login_as(user)

    spending_proposal = create(:spending_proposal,
                                valuation_finished: true,
                                feasible: false,
                                feasible_explanation: 'Local government is not competent in this matter')

    visit spending_proposal_path(spending_proposal)

    expect(page).to have_content("Unfeasibility explanation")
    expect(page).to have_content(spending_proposal.feasible_explanation)
  end

  context "Destroy" do

    scenario "Admin cannot destroy spending proposals" do
      admin = create(:administrator)
      user = create(:user, :level_two)
      spending_proposal = create(:spending_proposal, author: user)

      login_as(admin.user)

      visit user_path(user)
      within("#spending_proposal_#{spending_proposal.id}") do
        expect(page).to_not have_link "Delete"
      end
    end

  end

  context "Badge" do

    scenario "Spending proposal created by a Foum" do
      forum = create(:forum)
      spending_proposal = create(:spending_proposal, forum: true)

      visit spending_proposal_path(spending_proposal)
      expect(page).to have_css ".is-forum"

      visit spending_proposals_path
      within "#spending_proposal_#{spending_proposal.id}" do
        expect(page).to have_css ".is-forum"
      end
    end

    scenario "Spending proposal created by a User" do
      user = create(:user)
      user_spending_proposal = create(:spending_proposal)

      visit spending_proposal_path(user_spending_proposal)
      expect(page).to_not have_css "is-forum"

      visit spending_proposals_path(user_spending_proposal)
      within "#spending_proposal_#{user_spending_proposal.id}" do
        expect(page).to_not have_css "is-forum"
      end
    end

  end

  context "Phase 3 - Final Voting" do

    background do
      Setting["feature.spending_proposal_features.phase3"] = true
    end

    scenario "Index" do
      user = create(:user, :level_two)
      sp1 = create(:spending_proposal, :feasible, :finished, price: 10000)
      sp2 = create(:spending_proposal, :feasible, :finished, price: 20000)

      login_as(user)
      visit root_path

      first(:link, "Participatory budgeting").click
      click_link "Vote city proposals"

      within("#spending_proposal_#{sp1.id}") do
        expect(page).to have_content sp1.title
        expect(page).to have_content "$10,000"
      end

      within("#spending_proposal_#{sp2.id}") do
        expect(page).to have_content sp2.title
        expect(page).to have_content "$20,000"
      end
    end

    scenario 'Order by cost (only in phase3)' do
      create(:spending_proposal, :feasible, :finished, title: 'Build a nice house',  price:  1000).update_column(:confidence_score, 10)
      create(:spending_proposal, :feasible, :finished, title: 'Build an ugly house', price:  1000).update_column(:confidence_score, 5)
      create(:spending_proposal, :feasible, :finished, title: 'Build a skyscraper',  price: 20000)

      visit spending_proposals_path

      click_link 'by price'
      expect(page).to have_selector('a.active', text: 'by price')

      within '#investment-projects' do
        expect('Build a skyscraper').to appear_before('Build a nice house')
        expect('Build a nice house').to appear_before('Build an ugly house')
      end

      expect(current_url).to include('order=price')
      expect(current_url).to include('page=1')
    end

    scenario "Show" do
      user = create(:user, :level_two)
      sp1 = create(:spending_proposal, :feasible, :finished, price: 10000)

      login_as(user)
      visit root_path

      first(:link, "Participatory budgeting").click
      click_link "Vote city proposals"

      click_link sp1.title

      expect(page).to have_content "$10,000"
    end

    scenario "Confirm", :js do
      user = create(:user, :level_two)
      carabanchel = create(:geozone, name: "Carabanchel")
      new_york = create(:geozone)
      sp1 = create(:spending_proposal, :feasible, :finished, price:      1, geozone: nil)
      sp2 = create(:spending_proposal, :feasible, :finished, price:     10, geozone: nil)
      sp3 = create(:spending_proposal, :feasible, :finished, price:    100, geozone: nil)
      sp4 = create(:spending_proposal, :feasible, :finished, price:   1000, geozone: carabanchel)
      sp5 = create(:spending_proposal, :feasible, :finished, price:  10000, geozone: carabanchel)
      sp6 = create(:spending_proposal, :feasible, :finished, price: 100000, geozone: new_york)

      login_as(user)
      visit root_path

      first(:link, "Participatory budgeting").click
      click_link "Vote city proposals"

      add_to_ballot(sp1)
      add_to_ballot(sp2)

      first(:link, "Participatory budgeting").click
      click_link "Vote district proposals"
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
