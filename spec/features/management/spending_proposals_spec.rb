require 'rails_helper'

feature 'Spending Proposals' do

  background do
    Setting['feature.spending_proposals'] = true
    Setting['feature.spending_proposal_features.voting_allowed'] = true
    login_as_manager
  end

  after do
    Setting['feature.spending_proposals'] = nil
    Setting['feature.spending_proposal_features.voting_allowed'] = nil
  end

  context "Create" do

    scenario 'Creating spending proposals on behalf of someone' do
      user = create(:user, :level_two)
      login_managed_user(user)

      click_link "Create spending proposal"

      within(".account-info") do
        expect(page).to have_content "Identified as"
        expect(page).to have_content (user.username).to_s
        expect(page).to have_content (user.email).to_s
        expect(page).to have_content (user.document_number).to_s
      end

      fill_in 'spending_proposal_title', with: 'Build a park in my neighborhood'
      fill_in 'spending_proposal_description', with: 'There is no parks here...'
      fill_in 'spending_proposal_external_url', with: 'http://moarparks.com'
      check 'spending_proposal_terms_of_service'

      click_button 'Create'

      expect(page).to have_content 'Spending proposal created successfully.'

      expect(page).to have_content 'Build a park in my neighborhood'
      expect(page).to have_content 'There is no parks here...'
      expect(page).to have_content 'All city'
      expect(page).to have_content 'http://moarparks.com'
      expect(page).to have_content user.name
      expect(page).to have_content I18n.l(SpendingProposal.last.created_at.to_date)

      expect(current_path).to eq(management_spending_proposal_path(SpendingProposal.last))
    end

    scenario "Should not allow unverified users to create spending proposals" do
      user = create(:user)
      login_managed_user(user)

      click_link "Create spending proposal"

      expect(page).to have_content "User is not verified"
    end
  end

  context "Searching" do
    scenario "by title" do
      spending_proposal1 = create(:spending_proposal, title: "Show me what you got")
      spending_proposal2 = create(:spending_proposal, title: "Get Schwifty")

      user = create(:user, :level_two)
      login_managed_user(user)

      click_link "Support spending proposals"

      fill_in "search", with: "what you got"
      click_button "Search"

      expect(current_path).to eq(management_spending_proposals_path)

      within("#investment-projects") do
        expect(page).to have_css('.investment-project', count: 1)
        expect(page).to have_content(spending_proposal1.title)
        expect(page).to_not have_content(spending_proposal2.title)
        expect(page).to have_css("a[href='#{management_spending_proposal_path(spending_proposal1)}']", text: spending_proposal1.title)
        expect(page).to have_css("a[href='#{management_spending_proposal_path(spending_proposal1)}']", text: spending_proposal1.description)
      end
    end

    scenario "by district" do
      spending_proposal1 = create(:spending_proposal, title: "Hey ho", geozone_id: create(:geozone, name: "District 9").id)
      spending_proposal2 = create(:spending_proposal, title: "Let's go", geozone_id: create(:geozone, name: "Area 52").id)

      user = create(:user, :level_two)
      login_managed_user(user)

      click_link "Support spending proposals"

      fill_in "search", with: "Area 52"
      click_button "Search"

      expect(current_path).to eq(management_spending_proposals_path)

      within("#investment-projects") do
        expect(page).to have_css('.investment-project', count: 1)
        expect(page).to_not have_content(spending_proposal1.title)
        expect(page).to have_content(spending_proposal2.title)
        expect(page).to have_css("a[href='#{management_spending_proposal_path(spending_proposal2)}']", text: spending_proposal2.title)
        expect(page).to have_css("a[href='#{management_spending_proposal_path(spending_proposal2)}']", text: spending_proposal2.description)
      end
    end
  end

  scenario "Listing" do
    spending_proposal1 = create(:spending_proposal, title: "Show me what you got")
    spending_proposal2 = create(:spending_proposal, title: "Get Schwifty")

    user = create(:user, :level_two)
    login_managed_user(user)

    click_link "Support spending proposals"

    expect(current_path).to eq(management_spending_proposals_path)

    within(".account-info") do
      expect(page).to have_content "Identified as"
      expect(page).to have_content (user.username).to_s
      expect(page).to have_content (user.email).to_s
      expect(page).to have_content (user.document_number).to_s
    end

    within("#investment-projects") do
      expect(page).to have_css('.investment-project', count: 2)
      expect(page).to have_css("a[href='#{management_spending_proposal_path(spending_proposal1)}']", text: spending_proposal1.title)
      expect(page).to have_css("a[href='#{management_spending_proposal_path(spending_proposal1)}']", text: spending_proposal1.description)
      expect(page).to have_css("a[href='#{management_spending_proposal_path(spending_proposal2)}']", text: spending_proposal2.title)
      expect(page).to have_css("a[href='#{management_spending_proposal_path(spending_proposal2)}']", text: spending_proposal2.description)
    end
  end

  context "Voting" do

    scenario 'Voting spending proposals on behalf of someone in index view', :js do
      spending_proposal = create(:spending_proposal)

      user = create(:user, :level_two)
      login_managed_user(user)

      click_link "Support spending proposals"

      within("#investment-projects") do
        find('.in-favor a').click

        expect(page).to have_content "1 support"
        expect(page).to have_content "You have already supported this. Share it!"
      end
      expect(current_path).to eq(management_spending_proposals_path)
    end

    scenario 'Voting spending proposals on behalf of someone in show view', :js do
      spending_proposal = create(:spending_proposal)

      user = create(:user, :level_two)
      login_managed_user(user)

      click_link "Support spending proposals"

      within("#investment-projects") do
        click_link spending_proposal.title
      end

      find('.in-favor a').click
      expect(page).to have_content "1 support"
      expect(page).to have_content "You have already supported this. Share it!"
      expect(current_path).to eq(management_spending_proposal_path(spending_proposal))
    end

    scenario "Should not allow unverified users to vote proposals" do
      spending_proposal = create(:spending_proposal)

      user = create(:user)
      login_managed_user(user)

      click_link "Support spending proposals"

      expect(page).to have_content "User is not verified"
    end
  end

  context "Printing" do

    scenario 'Printing spending proposals' do
      16.times { create(:spending_proposal, geozone_id: nil) }

      click_link "Print spending proposals"

      expect(page).to have_css('.investment-project', count: 15)
      expect(page).to have_css("a[href='javascript:window.print();']", text: 'Print')
    end

    scenario "Filtering spending proposals by geozone to be printed", :js do
      district_9 = create(:geozone, name: "District Nine")
      create(:spending_proposal, title: 'Change district 9', geozone: district_9, cached_votes_up: 10)
      create(:spending_proposal, title: 'Destroy district 9', geozone: district_9, cached_votes_up: 100)
      create(:spending_proposal, title: 'Nuke district 9', geozone: district_9, cached_votes_up: 1)
      create(:spending_proposal, title: 'Add new districts to the city', geozone_id: nil)

      user = create(:user, :level_two)
      login_managed_user(user)

      click_link "Print spending proposals"

      expect(page).to have_content "Investment projects with scope: All city"

      within '#investment-projects' do
        expect(page).to have_content('Add new districts to the city')
        expect(page).to_not have_content('Change district 9')
        expect(page).to_not have_content('Destroy district 9')
        expect(page).to_not have_content('Nuke district 9')
      end

      select 'District Nine', from: 'geozone'

      expect(page).to have_content "Investment projects with scope: District Nine"
      expect(current_url).to include("geozone=#{district_9.id}")

      within '#investment-projects' do
        expect(page).to_not have_content('Add new districts to the city')
        expect('Destroy district 9').to appear_before('Change district 9')
        expect('Change district 9').to appear_before('Nuke district 9')
      end
    end

  end

end
