require 'rails_helper'

feature 'Moderate proposals' do

  scenario 'Hide', :js do
    citizen = create(:user)
    moderator = create(:moderator)

    proposal = create(:proposal)

    login_as(moderator.user)
    visit proposal_path(proposal)

    within("#proposal_#{proposal.id}") do
      click_link 'Hide'
    end

    expect(page).to have_css("#proposal_#{proposal.id}.faded")

    login_as(citizen)
    visit proposals_path

    expect(page).to have_css('.proposal', count: 0)
  end

  scenario 'Can not hide own proposal' do
    moderator = create(:moderator)
    proposal = create(:proposal, author: moderator.user)

    login_as(moderator.user)
    visit proposal_path(proposal)

    within("#proposal_#{proposal.id}") do
      expect(page).to_not have_link('Hide')
      expect(page).to_not have_link('Block author')
    end
  end
end
