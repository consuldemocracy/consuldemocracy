require 'rails_helper'

feature 'Admin activity' do

  background do
    @admin = create(:administrator)
    login_as(@admin.user)
  end

  context "Proposals" do
    scenario "Shows moderation activity on proposals", :js do
      proposal = create(:proposal)

      visit proposal_path(proposal)

      within("#proposal_#{proposal.id}") do
        click_link 'Hide'
      end

      visit admin_activity_path

      within("#activity_#{Activity.last.id}") do
        expect(page).to have_content(proposal.title)
        expect(page).to have_content(@admin.user.username)
      end
    end

    scenario "Shows moderation activity from moderation screen" do
      proposal1 = create(:proposal)
      proposal2 = create(:proposal)
      proposal3 = create(:proposal)

      visit moderation_proposals_path(filter: 'all')

      within("#proposal_#{proposal1.id}") do
        check "proposal_#{proposal1.id}_check"
      end

      within("#proposal_#{proposal3.id}") do
        check "proposal_#{proposal3.id}_check"
      end

      click_on "Hide proposals"

      visit admin_activity_path


      expect(page).to have_content(proposal1.title)
      expect(page).to_not have_content(proposal2.title)
      expect(page).to have_content(proposal3.title)
    end
  end

end