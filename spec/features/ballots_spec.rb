require 'rails_helper'

feature 'Ballots' do

  background do
    Setting['feature.spending_proposal_features.phase3'] = true
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