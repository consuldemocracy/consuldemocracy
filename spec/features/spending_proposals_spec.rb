require 'rails_helper'

feature 'Spending proposals' do

  let(:author) { create(:user, :level_two, username: 'Isabel') }

  background do
    Setting['feature.spending_proposals'] = true
    Setting['feature.spending_proposal_features.voting_allowed'] = true
  end

  after do
    Setting['feature.spending_proposals'] = nil
    Setting['feature.spending_proposal_features.voting_allowed'] = nil
  end

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
      spending_proposal5 = create(:spending_proposal, feasible: false, valuation_finished: true, geozone: create(:geozone))

      visit spending_proposals_path(unfeasible: 1)

      within("#investment-projects") do
        expect(page).to have_css('.investment-project', count: 2)

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
      (per_page * 100).times { create(:spending_proposal) }

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

    expect(page).to have_content 'Spending proposal created successfully'
    expect(page).to have_content 'You can access it from My activity'
  end

  xscenario 'Errors on create' do
    login_as(author)

    visit new_spending_proposal_path
    click_button 'Create'
    expect(page).to have_content error_message
  end

  scenario "Show" do
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

    xscenario "Admin cannot destroy spending proposals" do
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

    xscenario "Index" do
      user = create(:user, :level_two)
      sp1 = create(:spending_proposal, :feasible, :finished, price: 10000)
      sp2 = create(:spending_proposal, :feasible, :finished, price: 20000)

      login_as(user)
      visit root_path

      first(:link, "Spending proposals").click
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

    xscenario "Show" do
      user = create(:user, :level_two)
      sp1 = create(:spending_proposal, :feasible, :finished, price: 10000)

      login_as(user)
      visit root_path

      first(:link, "Spending proposals").click
      click_link "Vote city proposals"

      click_link sp1.title

      expect(page).to have_content "$10,000"
    end

    xscenario "Confirm", :js do
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

      first(:link, "Spending proposals").click
      click_link "Vote city proposals"

      add_spending_proposal_to_ballot(sp1)
      add_spending_proposal_to_ballot(sp2)

      first(:link, "Spending proposals").click
      click_link "Vote district proposals"
      click_link carabanchel.name

      add_spending_proposal_to_ballot(sp4)
      add_spending_proposal_to_ballot(sp5)

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


  context 'Results' do

    before(:each) do
      Setting["feature.spending_proposal_features.open_results_page"] = true
    end

    after(:each) do
      Setting["feature.spending_proposal_features.open_results_page"] = nil
    end

    context "Diplays proposals ordered by ballot_lines_count" do

      background do
        @california = create(:geozone)

        @proposal1 = create(:spending_proposal, :finished, :feasible, price: 10, ballot_lines_count: 20, geozone: nil)
        @proposal2 = create(:spending_proposal, :finished, :feasible, price: 10, ballot_lines_count: 60, geozone: nil)
        @proposal3 = create(:spending_proposal, :finished, :feasible, price: 10, ballot_lines_count: 40, geozone: nil)
        @proposal4 = create(:spending_proposal, :finished, :feasible, price: 10, ballot_lines_count: 33, geozone: @california)
        @proposal5 = create(:spending_proposal, :finished, :feasible, price: 10, ballot_lines_count: 99, geozone: @california)
        @proposal6 = create(:spending_proposal, :finished, :feasible, price: 10, ballot_lines_count: 11, geozone: @california)
        @proposal7 = create(:spending_proposal, :finished, :feasible, price: 10, ballot_lines_count: 100, geozone: create(:geozone))
      end

      scenario "Spending proposals with no geozone" do
        visit participatory_budget_results_path

        within("#results-container") do
          expect(page).to have_content "All city"
        end

        within("#spending-proposals-results") do
          expect(page).to have_content @proposal1.title
          expect(page).to have_content @proposal2.title
          expect(page).to have_content @proposal3.title
          expect(page).to_not have_content @proposal4.title
          expect(page).to_not have_content @proposal5.title
          expect(page).to_not have_content @proposal6.title
          expect(page).to_not have_content @proposal7.title

          within("#spending_proposal_#{@proposal1.id}") { expect(page).to have_content "20" }
          within("#spending_proposal_#{@proposal2.id}") { expect(page).to have_content "60" }
          within("#spending_proposal_#{@proposal3.id}") { expect(page).to have_content "40" }

          expect(@proposal2.title).to appear_before(@proposal3.title)
          expect(@proposal3.title).to appear_before(@proposal1.title)
        end
      end

      scenario "Geozoned spending proposals", :js do
        visit participatory_budget_results_path(geozone_id: @california.id)
        click_link "Show all"

        within("#spending-proposals-results") do
          expect(page).to_not have_content @proposal1.title
          expect(page).to_not have_content @proposal2.title
          expect(page).to_not have_content @proposal3.title
          expect(page).to have_content @proposal4.title
          expect(page).to have_content @proposal5.title
          expect(page).to have_content @proposal6.title
          expect(page).to_not have_content @proposal7.title

          expect(@proposal5.title).to appear_before(@proposal4.title)
          expect(@proposal4.title).to appear_before(@proposal6.title)
        end
      end

      context "Compatible spending proposals" do

        scenario "Include compatible spending proposals in results" do
          compatible_proposal1 = create(:spending_proposal, :finished, :feasible, price: 10, compatible: true)
          compatible_proposal2 = create(:spending_proposal, :finished, :feasible, price: 10, compatible: true)

          incompatible_proposal = create(:spending_proposal, :finished, :feasible, price: 10, compatible: false)

          visit participatory_budget_results_path(geozone_id: nil)

          within("#spending-proposals-results") do
            expect(page).to have_content compatible_proposal1.title
            expect(page).to have_content compatible_proposal2.title

            expect(page).to_not have_content incompatible_proposal.title
          end
        end

        scenario "Display incompatible spending proposals after results", :js do
          incompatible_proposal1 = create(:spending_proposal, :finished, :feasible, price: 10, compatible: false)
          incompatible_proposal2 = create(:spending_proposal, :finished, :feasible, price: 10, compatible: false)

          compatible_proposal = create(:spending_proposal, :finished, :feasible, price: 10, compatible: true)

          visit participatory_budget_results_path(geozone_id: nil)
          click_link "Show all"

          within("#incompatible-spending-proposals") do
            expect(page).to have_content incompatible_proposal1.title
            expect(page).to have_content incompatible_proposal2.title

            expect(page).to_not have_content compatible_proposal.title
          end
        end

        scenario "Incompatible and not winners are hidden by default", :js do
          centro = create(:geozone, name: "Centro") #budget: 1353966
          proposal1 = create(:spending_proposal, :finished, :feasible, price: 1000000, ballot_lines_count: 999, geozone: centro)
          proposal2 = create(:spending_proposal, :finished, :feasible, price:  900000, ballot_lines_count: 888, geozone: centro)
          proposal3 = create(:spending_proposal, :finished, :feasible, price:  350000, ballot_lines_count: 777, geozone: centro)
          incompatible_proposal = create(:spending_proposal, :finished, :feasible, price: 10, compatible: false, geozone: centro)

          visit participatory_budget_results_path(geozone_id: centro.id)

          within("#spending-proposals-results") do
            expect(proposal1.title).to appear_before(proposal3.title)

            expect(page).to_not have_content(proposal2.title)
            expect(page).to_not have_content(incompatible_proposal.title)
          end

          click_link "Show all"

          within("#spending-proposals-results") do
            expect(proposal1.title).to appear_before(proposal2.title)
            expect(proposal2.title).to appear_before(proposal3.title)
          end
          expect(proposal3.title).to appear_before(incompatible_proposal.title)
        end

      end

      scenario "Delegated votes affecting the result" do
        forum = create(:forum)
        create_list(:user, 30, :level_two, representative: forum)
        forum.ballot.spending_proposals << @proposal3

        visit participatory_budget_results_path

        expect(page).to have_content @proposal1.title
        expect(page).to have_content @proposal2.title
        expect(page).to have_content @proposal3.title

        within("#spending_proposal_#{@proposal1.id}") { expect(page).to have_content "20" }
        within("#spending_proposal_#{@proposal2.id}") { expect(page).to have_content "60" }
        within("#spending_proposal_#{@proposal3.id}") { expect(page).to have_content "70" }

        expect(@proposal3.title).to appear_before(@proposal2.title)
        expect(@proposal2.title).to appear_before(@proposal1.title)
      end
    end

    scenario "Displays only finished feasible spending proposals", :js do
      california = create(:geozone)

      proposal1 = create(:spending_proposal, :finished, :feasible, price: 10, ballot_lines_count: 20, geozone: california)
      proposal2 = create(:spending_proposal, :finished, price: 10, ballot_lines_count: 60, geozone: california)
      proposal3 = create(:spending_proposal, :feasible, price: 10, ballot_lines_count: 40, geozone: california)
      proposal4 = create(:spending_proposal, price: 10, ballot_lines_count: 40, geozone: california)

      visit participatory_budget_results_path(geozone_id: california.id)
      click_link "Show all"

      within("#spending-proposals-results") do
        expect(page).to have_content proposal1.title
        expect(page).to_not have_content proposal2.title
        expect(page).to_not have_content proposal3.title
        expect(page).to_not have_content proposal4.title
      end
    end

    scenario "Highlights winner candidates (within budget), if tied most expensive first", :js do
      centro = create(:geozone, name: "Centro") #budget: 1353966

      proposal1 = create(:spending_proposal, :finished, :feasible, price: 1000000, ballot_lines_count: 999, geozone: centro)
      proposal2 = create(:spending_proposal, :finished, :feasible, price:  900000, ballot_lines_count: 888, geozone: centro)
      proposal3 = create(:spending_proposal, :finished, :feasible, price:  700000, ballot_lines_count: 777, geozone: centro)
      proposal4 = create(:spending_proposal, :finished, :feasible, price:  350000, ballot_lines_count: 666, geozone: centro)
      proposal5 = create(:spending_proposal, :finished, :feasible, price:  320000, ballot_lines_count: 666, geozone: centro)
      proposal6 = create(:spending_proposal, :finished, :feasible, price:      10, ballot_lines_count: 555, geozone: centro)

      visit participatory_budget_results_path(geozone_id: centro.id)
      click_link "Show all"

      within("#spending-proposals-results") do
        expect(proposal1.title).to appear_before(proposal2.title)
        expect(proposal2.title).to appear_before(proposal3.title)
        expect(proposal3.title).to appear_before(proposal4.title)
        expect(proposal4.title).to appear_before(proposal5.title)
        expect(proposal5.title).to appear_before(proposal6.title)

        expect(page).to have_css("#spending_proposal_#{proposal1.id}.success")
        expect(page).to have_css("#spending_proposal_#{proposal4.id}.success")
        expect(page).to have_css("#spending_proposal_#{proposal6.id}.success")
        expect(page).to_not have_css("#spending_proposal_#{proposal2.id}.success")
        expect(page).to_not have_css("#spending_proposal_#{proposal3.id}.success")
        expect(page).to_not have_css("#spending_proposal_#{proposal5.id}.success")
      end
    end
  end

  context "Stats" do

    before(:each) do
      Setting["feature.spending_proposal_features.open_results_page"] = true
    end

    after(:each) do
      Setting["feature.spending_proposal_features.open_results_page"] = nil
    end

    scenario "Participation" do
      isabel   = create(:user, :level_two)
      eva      = create(:user, :level_two)
      antonio  = create(:user, :level_two)
      jose     = create(:user, :level_two)
      josefine = create(:user, :level_two)
      edward   = create(:user, :level_two)

      create_spending_proposal_for(isabel)
      create_vote_for(eva)
      create_ballot_for(antonio)
      create_delegation_for(jose, josefine)

      visit stats_spending_proposals_path

      within "#total_participants" do
        expect(page).to have_content "5"
      end
    end

    scenario "Total participation in phases" do
      isabel   = create(:user, :level_two)
      eva      = create(:user, :level_two)
      antonio  = create(:user, :level_two)
      jose     = create(:user, :level_two)
      josefine = create(:user, :level_two)
      edward   = create(:user, :level_two)

      create_spending_proposal_for(isabel)
      create_vote_for(eva, antonio)
      create_ballot_for(eva, jose, josefine)

      visit stats_spending_proposals_path

      within "#total_participants_support_phase" do
        expect(page).to have_content "2"
      end

      within "#total_participants_vote_phase" do
        expect(page).to have_content "3"
      end
    end

    scenario "Total supports" do
      isabel   = create(:user, :level_two)
      eva      = create(:user, :level_two)
      antonio  = create(:user, :level_two)
      jose     = create(:user, :level_two)
      josefine = create(:user, :level_two)
      edward   = create(:user, :level_two)

      create_spending_proposal_for(isabel)
      create_vote_for(eva, antonio, jose, josefine)

      visit stats_spending_proposals_path

      within "#total_supports" do
        expect(page).to have_content "4"
      end
    end

    scenario "Total votes" do
      isabel   = create(:user, :level_two)
      eva      = create(:user, :level_two)
      antonio  = create(:user, :level_two)
      jose     = create(:user, :level_two)
      josefine = create(:user, :level_two)
      edward   = create(:user, :level_two)

      create_spending_proposal_for(isabel)
      create_ballot_for(eva, antonio, jose, josefine, isabel)

      visit stats_spending_proposals_path

      within "#total_votes" do
        expect(page).to have_content "5"
      end
    end

    scenario "Investment projects" do
      sp1 = create(:spending_proposal, :finished, :feasible)
      sp2 = create(:spending_proposal, :finished, :feasible)
      sp3 = create(:spending_proposal, :finished, :unfeasible)

      visit stats_spending_proposals_path

      within "#total_spending_proposals" do
        expect(page).to have_content "115" # 3 + 112 paper spending proposals
      end

      within "#total_feasible_spending_proposals" do
        expect(page).to have_content "2"
      end

      within "#total_unfeasible_spending_proposals" do
        expect(page).to have_content "1"
      end
    end

    scenario "Gender" do
      isabel  = create(:user, :level_two, gender: 'female')
      eva     = create(:user, :level_two, gender: 'female')
      antonio = create(:user, :level_two, gender: 'male')

      create_spending_proposal_for(isabel)
      create_vote_for(isabel, eva, antonio)

      visit stats_spending_proposals_path

      within "#total_male_participants" do
        expect(page).to have_content "1"
      end

      within "#total_female_participants" do
        expect(page).to have_content "2"
      end

      within "#male_percentage" do
        expect(page).to have_content "33.33%"
      end

      within "#female_percentage" do
        expect(page).to have_content "66.67%"
      end
    end

    scenario "Gender unknown" do
      isabel  = create(:user, :level_two, gender: 'female')
      unknown = create(:user, :level_two, gender:  nil)
      antonio = create(:user, :level_two, gender: 'male')

      create_spending_proposal_for(isabel)
      create_vote_for(isabel, unknown, antonio)

      visit stats_spending_proposals_path

      within "#total_participants" do
        expect(page).to have_content "3"
      end

      within "#total_male_participants" do
        expect(page).to have_content "1"
      end

      within "#total_female_participants" do
        expect(page).to have_content "1"
      end

      within "#male_percentage" do
        expect(page).to have_content "50%"
      end

      within "#female_percentage" do
        expect(page).to have_content "50%"
      end
    end

    scenario "Age group" do
      isabel  = create(:user, :level_two, date_of_birth: 17.years.ago)
      eva     = create(:user, :level_two, date_of_birth: 18.years.ago)
      antonio = create(:user, :level_two, date_of_birth: 36.years.ago)

      create_vote_for(isabel, eva, antonio)

      visit stats_spending_proposals_path

      #Take into account users that do not have a date of birth in the foot note...
      #take into account unknown ages when calculating percentage in table?
      within "#age_group_16_to_19" do
        expect(page).to have_content "16 - 19"
        expect(page).to have_content "2 (50%)"
      end

      # this is for previously-created manuela user, which comes with a default age of 20
      within "#age_group_20_to_24" do
        expect(page).to have_content "20 - 24"
        expect(page).to have_content "1 (25%)"
      end

      within "#age_group_35_to_39" do
        expect(page).to have_content "35 - 39"
        expect(page).to have_content "1 (25%)"
      end
    end

    scenario "Unknown sex or gender" do
      isabel  = create(:user, :level_two, gender: 'female', date_of_birth: 17.years.ago)
      antonio = create(:user, :level_two, gender: 'male',   date_of_birth: 17.years.ago)
      unknown = create(:user, :level_two, gender:  nil,     date_of_birth: 17.years.ago)

      eva      = create(:user, :level_two, gender: 'female', date_of_birth: 17.years.ago)
      jose     = create(:user, :level_two, gender: 'male',   date_of_birth: 17.years.ago)
      unknown2 = create(:user, :level_two, gender:  nil,     date_of_birth: nil)

      create_spending_proposal_for(isabel)
      create_vote_for(isabel, antonio, unknown, eva, jose, unknown2)

      visit stats_spending_proposals_path

      within "#total_unknown_gender_or_age" do
        expect(page).to have_content "2"
      end
    end

    context "Geozones" do

      scenario "Investment projects" do
        california = create(:geozone)
        new_york = create(:geozone)

        sp1 = create(:spending_proposal, geozone: california)
        sp2 = create(:spending_proposal, geozone: california)
        sp3 = create(:spending_proposal, geozone: new_york)

        visit stats_spending_proposals_path

        within("#total_spending_proposals_geozone_#{california.id}") do
          expect(page).to have_content "2"
        end

        within("#total_spending_proposals_geozone_#{new_york.id}") do
          expect(page).to have_content "1"
        end
      end

      context "Support phase" do

        background do
          @barajas = create(:geozone, name: "Barajas")
          @carabanchel = create(:geozone, name: "Carabanchel")

          isabel   = create(:user, :level_two)
          eva      = create(:user, :level_two)
          antonio  = create(:user, :level_two)

          jose     = create(:user, :level_two)
          josefine = create(:user, :level_two)
          edward   = create(:user, :level_two)

          sp1 = create(:spending_proposal, geozone: @barajas,     author: isabel)
          sp2 = create(:spending_proposal, geozone: @carabanchel, author: jose)
          sp3 = create(:spending_proposal, geozone: @carabanchel, author: jose)

          create(:vote, votable: sp1, voter: isabel)
          create(:vote, votable: sp1, voter: eva)
          create(:vote, votable: sp1, voter: antonio)

          create(:vote, votable: sp2, voter: jose)
          create(:vote, votable: sp3, voter: josefine)
        end

        scenario "Total participation" do
          visit stats_spending_proposals_path

          within("#total_participants_support_phase_geozone_#{@barajas.id}") do
            expect(page).to have_content "3"
          end

          within("#total_participants_support_phase_geozone_#{@carabanchel.id}") do
            expect(page).to have_content "2"
          end
        end

        scenario "Percentage of total participation" do
          visit stats_spending_proposals_path

          within("#percentage_participants_support_phase_geozone_#{@barajas.id}") do
            expect(page).to have_content "60%"
          end

          within("#percentage_participants_support_phase_geozone_#{@carabanchel.id}") do
            expect(page).to have_content "40%"
          end
        end

        scenario "Percentage of district population" do
          allow_any_instance_of(SpendingProposalsController).
          to receive(:district_population).
          and_return({ "Barajas"     => 1000,
                       "Carabanchel" => 100})

          visit stats_spending_proposals_path

          within("#percentage_district_population_support_phase_geozone_#{@barajas.id}") do
            expect(page).to have_content "3%"
          end

          within("#percentage_district_population_support_phase_geozone_#{@carabanchel.id}") do
            expect(page).to have_content "2%"
          end
        end
      end

      context "Vote phase" do

        background do
          @barajas = create(:geozone, name: "Barajas")
          @carabanchel = create(:geozone, name: "Carabanchel")

          isabel   = create(:user, :level_two)
          eva      = create(:user, :level_two)
          antonio  = create(:user, :level_two)

          jose     = create(:user, :level_two)
          josefine = create(:user, :level_two)
          edward   = create(:user, :level_two)

          sp1 = create(:spending_proposal, :finished, :feasible, geozone: @barajas)
          sp2 = create(:spending_proposal, :finished, :feasible, geozone: @carabanchel)
          sp3 = create(:spending_proposal, :finished, :feasible, geozone: @carabanchel)

          create(:ballot, spending_proposals: [sp1], user: isabel,  geozone: @barajas)
          create(:ballot, spending_proposals: [sp1], user: eva,     geozone: @barajas)
          create(:ballot, spending_proposals: [sp1], user: antonio, geozone: @barajas)

          create(:ballot, spending_proposals: [sp2], user: jose,     geozone: @carabanchel)
          create(:ballot, spending_proposals: [sp3], user: josefine, geozone: @carabanchel)
        end

        scenario "Total participation" do
          visit stats_spending_proposals_path

          within("#total_participants_vote_phase_geozone_#{@barajas.id}") do
            expect(page).to have_content "3"
          end

          within("#total_participants_vote_phase_geozone_#{@carabanchel.id}") do
            expect(page).to have_content "2"
          end
        end

        scenario "Percentage of total participation" do
          visit stats_spending_proposals_path

          within("#percentage_participants_vote_phase_geozone_#{@barajas.id}") do
            expect(page).to have_content "60%"
          end

          within("#percentage_participants_vote_phase_geozone_#{@carabanchel.id}") do
            expect(page).to have_content "40%"
          end
        end

        scenario "Percentage of district population" do
          allow_any_instance_of(SpendingProposalsController).
          to receive(:district_population).
          and_return({ "Barajas"     => 1000,
                       "Carabanchel" => 100})

          visit stats_spending_proposals_path

          within("#percentage_district_population_vote_phase_geozone_#{@barajas.id}") do
            expect(page).to have_content "0.3%"
          end

          within("#percentage_district_population_vote_phase_geozone_#{@carabanchel.id}") do
            expect(page).to have_content "2%"
          end
        end
      end

      context "All phases" do

        background do
          @barajas = create(:geozone, name: "Barajas")
          @carabanchel = create(:geozone, name: "Carabanchel")

          isabel   = create(:user, :level_two)
          eva      = create(:user, :level_two)
          antonio  = create(:user, :level_two)

          jose     = create(:user, :level_two)
          josefine = create(:user, :level_two)
          edward   = create(:user, :level_two)

          sp1 = create(:spending_proposal, :finished, :feasible, geozone: @barajas,     author: isabel)
          sp2 = create(:spending_proposal, :finished, :feasible, geozone: @carabanchel, author: jose)
          sp3 = create(:spending_proposal, :finished, :feasible, geozone: @carabanchel, author: jose)

          create(:vote, votable: sp1, voter: isabel)
          create(:vote, votable: sp1, voter: eva)
          create(:vote, votable: sp1, voter: antonio)

          create(:vote, votable: sp2, voter: jose)
          create(:vote, votable: sp3, voter: josefine)

          create(:ballot, spending_proposals: [sp1], user: isabel,  geozone: @barajas)
          create(:ballot, spending_proposals: [sp1], user: eva,     geozone: @barajas)
          create(:ballot, spending_proposals: [sp1], user: antonio, geozone: @barajas)

          create(:ballot, spending_proposals: [sp2], user: jose,     geozone: @carabanchel)
          create(:ballot, spending_proposals: [sp3], user: josefine, geozone: @carabanchel)
          create(:ballot, spending_proposals: [sp3], user: edward,   geozone: @carabanchel)
        end

        scenario "Total participation" do
          visit stats_spending_proposals_path

          within("#total_participants_all_phase_geozone_#{@barajas.id}") do
            expect(page).to have_content "3"
          end

          within("#total_participants_all_phase_geozone_#{@carabanchel.id}") do
            expect(page).to have_content "3"
          end
        end

        scenario "Percentage of total participation" do
          visit stats_spending_proposals_path

          within("#percentage_participants_all_phase_geozone_#{@barajas.id}") do
            expect(page).to have_content "50%"
          end

          within("#percentage_participants_all_phase_geozone_#{@carabanchel.id}") do
            expect(page).to have_content "50%"
          end
        end

        scenario "Percentage of district population" do
          allow_any_instance_of(SpendingProposalsController).
          to receive(:district_population).
          and_return({ "Barajas"     => 1000,
                       "Carabanchel" => 100})

          visit stats_spending_proposals_path

          within("#percentage_district_population_all_phase_geozone_#{@barajas.id}") do
            expect(page).to have_content "0.3%"
          end

          within("#percentage_district_population_all_phase_geozone_#{@carabanchel.id}") do
            expect(page).to have_content "3%"
          end
        end

      end

      scenario "Disregard participantes that have not voted in district spending proposals" do
        @barajas      = create(:geozone, name: "Barajas")
        @carabanchel = create(:geozone, name: "Carabanchel")

        isabel   = create(:user, :level_two, supported_spending_proposals_geozone_id: @barajas.id)
        eva      = create(:user, :level_two, supported_spending_proposals_geozone_id: @carabanchel.id)
        antonio  = create(:user, :level_two)

        sp1 = create(:spending_proposal, :finished, :feasible, geozone: @barajas,     author: isabel)
        sp2 = create(:spending_proposal, :finished, :feasible, geozone: @carabanchel, author: eva)
        sp3 = create(:spending_proposal, :finished, :feasible, geozone: nil,          author: antonio)

        create(:vote, votable: sp1, voter: isabel)
        create(:vote, votable: sp2, voter: eva)
        create(:vote, votable: sp3, voter: antonio)

        create(:ballot, spending_proposals: [sp1], user: isabel,  geozone: @barajas)
        create(:ballot, spending_proposals: [sp2], user: eva,     geozone: @carabanchel)
        create(:ballot, spending_proposals: [sp3], user: antonio, geozone: nil)

        visit stats_spending_proposals_path

        within("#total_participants_support_phase_geozone_#{@barajas.id}") do
          expect(page).to have_content "1"
        end

        within("#total_participants_support_phase_geozone_#{@carabanchel.id}") do
          expect(page).to have_content "1"
        end

        within("#percentage_participants_support_phase_geozone_#{@barajas.id}") do
          expect(page).to have_content "50%"
        end

        within("#percentage_participants_support_phase_geozone_#{@carabanchel.id}") do
          expect(page).to have_content "50%"
        end


        within("#total_participants_vote_phase_geozone_#{@barajas.id}") do
          expect(page).to have_content "1"
        end

        within("#total_participants_vote_phase_geozone_#{@carabanchel.id}") do
          expect(page).to have_content "1"
        end

        within("#percentage_participants_vote_phase_geozone_#{@barajas.id}") do
          expect(page).to have_content "50%"
        end

        within("#percentage_participants_vote_phase_geozone_#{@carabanchel.id}") do
          expect(page).to have_content "50%"
        end


        within("#total_participants_all_phase_geozone_#{@barajas.id}") do
          expect(page).to have_content "1"
        end

        within("#total_participants_all_phase_geozone_#{@carabanchel.id}") do
          expect(page).to have_content "1"
        end

        within("#percentage_participants_all_phase_geozone_#{@barajas.id}") do
          expect(page).to have_content "50%"
        end

        within("#percentage_participants_all_phase_geozone_#{@carabanchel.id}") do
          expect(page).to have_content "50%"
        end
      end
    end
  end
end
