require 'rails_helper'

feature 'Ballots' do

  background do
    Setting['feature.spending_proposal_features.phase3'] = true
  end

  context 'Showing the ballot' do
    scenario 'Displaying the correct count & amount' do
      user = create(:user)
      ballot = create(:ballot, user: user)
      geozone = create(:geozone)

      ballot.spending_proposals =
        create_list(:spending_proposal, 2, price: 10) +
        create_list(:spending_proposal, 3, price: 5, geozone: geozone)

      login_as(user)
      visit ballot_path

      expect(page).to have_content("You voted 5 proposals with a total cost of 35€")
      within("#city_wide") { expect(page).to have_content "20€" }
      within("#district_wide") { expect(page).to have_content "15€" }
    end
  end

  scenario 'Removing spending proposals from ballot', :js do
    user = create(:user)
    ballot = create(:ballot, user: user)
    sp = create(:spending_proposal, price: 10)
    ballot.spending_proposals = [sp]

    login_as(user)
    visit ballot_path

    expect(page).to have_content("You voted one proposal with a total cost of 10€")

    within("#spending_proposal_#{sp.id}") do
      click_link "Remove vote"
    end

    expect(current_path).to eq(ballot_path)
    expect(page).to have_content("You voted 0 proposals with a total cost of 0")
  end

  context 'Permissions' do

    scenario 'User not logged in', :js do
      spending_proposal = create(:spending_proposal)

      visit spending_proposals_path

      within("#spending_proposal_#{spending_proposal.id}") do
        find("div.ballot").hover
        expect_message_you_need_to_sign_in
      end
    end

    scenario 'User not verified', :js do
      user = create(:user)
      spending_proposal = create(:spending_proposal)

      login_as(user)
      visit spending_proposals_path

      within("#spending_proposal_#{spending_proposal.id}") do
        find("div.ballot").hover
        expect_message_only_verified_can_vote_proposals
      end
    end

    scenario 'User is organization', :js do
      org = create(:organization)
      spending_proposal = create(:spending_proposal)

      login_as(org.user)
      visit spending_proposals_path

      within("#spending_proposal_#{spending_proposal.id}") do
        find("div.ballot").hover
        expect_message_organizations_cannot_vote
      end
    end

    scenario 'Spending proposal unfeasible', :js do
      user = create(:user, :level_two)
      spending_proposal = create(:spending_proposal, feasible: false, valuation_finished: true)

      login_as(user)
      visit spending_proposals_path(unfeasible: 1)

      within("#spending_proposal_#{spending_proposal.id}") do
        expect(page).to_not have_css("div.ballot")
      end
    end

    xscenario 'Wrong district' do
    end

  end
end
