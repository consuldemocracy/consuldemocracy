require 'rails_helper'

feature 'Proposals' do

  background do
    manager = create(:manager)
    login_as_manager(manager)
  end

  context "Create" do

    scenario 'Creating proposals on behalf of someone' do
      user = create(:user, :level_two)
      login_managed_user(user)

      click_link "Create proposal"

      fill_in 'proposal_title', with: 'Help refugees'
      fill_in 'proposal_question', with: '¿Would you like to give assistance to war refugees?'
      fill_in 'proposal_summary', with: 'In summary, what we want is...'
      fill_in 'proposal_description', with: 'This is very important because...'
      fill_in 'proposal_external_url', with: 'http://rescue.org/refugees'
      fill_in 'proposal_video_url', with: 'http://youtube.com'
      fill_in 'proposal_captcha', with: correct_captcha_text
      check 'proposal_terms_of_service'

      click_button 'Start a proposal'

      expect(page).to have_content 'Proposal was successfully created.'

      expect(page).to have_content 'Help refugees'
      expect(page).to have_content '¿Would you like to give assistance to war refugees?'
      expect(page).to have_content 'In summary, what we want is...'
      expect(page).to have_content 'This is very important because...'
      expect(page).to have_content 'http://rescue.org/refugees'
      expect(page).to have_content 'http://youtube.com'
      expect(page).to have_content user.name
      expect(page).to have_content I18n.l(Proposal.last.created_at.to_date)
    end

    scenario "Should not allow unverified users to create proposals" do
      user = create(:user)
      login_managed_user(user)

      click_link "Create proposal"

      expect(page).to have_content "User is not verified"
    end
  end

  context "Voting" do

    scenario 'Voting proposals on behalf of someone', :js do
      proposal = create(:proposal)

      user = create(:user, :level_two)
      login_managed_user(user)

      click_link "Support proposals"

      within("#proposals") do
        find('.in-favor a').click

        expect(page).to have_content "1 support"
        expect(page).to have_content "You already supported this proposal"
      end
      expect(URI.parse(current_url).path).to eq(management_proposals_path)
    end

    scenario "Should not allow unverified users to vote proposals" do
      proposal = create(:proposal)

      user = create(:user)
      login_managed_user(user)

      click_link "Support proposals"

      expect(page).to have_content "User is not verified"
    end

    scenario "Searching" do
      proposal1 = create(:proposal, title: "Show me what you got")
      proposal2 = create(:proposal, title: "Get Schwifty")

      user = create(:user, :level_two)
      login_managed_user(user)

      click_link "Support proposals"

      fill_in "search", with: "what you got"
      click_button "Search"

      expect(current_path).to eq(management_proposals_path)

      within("#proposals") do
        expect(page).to have_css('.proposal', count: 1)
        expect(page).to have_content(proposal1.title)
        expect(page).to_not have_content(proposal2.title)
      end
    end
  end

  context "Printing" do

    scenario 'Printing proposals', :js do
      5.times { create(:proposal) }

      click_link "Print proposals"

      find("#print_link").click

      ### CHANGE ME
      # should probably test something else here
      # maybe that we are loading a print.css stylesheet?
      ###
    end

    scenario "Filtering proposals to be printed", :js do
      create(:proposal, title: 'Best proposal').update_column(:confidence_score, 10)
      create(:proposal, title: 'Worst proposal').update_column(:confidence_score, 2)
      create(:proposal, title: 'Medium proposal').update_column(:confidence_score, 5)

      user = create(:user, :level_two)
      login_managed_user(user)

      click_link "Print proposals"

      select 'most supported', from: 'order-selector'

      expect(page).to have_selector('.js-order-selector[data-order="confidence_score"]')

      within '#proposals' do
        expect('Best proposal').to appear_before('Medium proposal')
        expect('Medium proposal').to appear_before('Worst proposal')
      end

      expect(current_url).to include('order=confidence_score')
      expect(current_url).to include('page=1')
    end

  end
end