require 'rails_helper'

feature 'Moderate debates' do

  scenario 'Hide', :js do
    citizen = create(:user)
    moderator = create(:moderator)

    debate = create(:debate)

    login_as(moderator.user)
    visit debate_path(debate)

    within("#debate_#{debate.id}") do
      click_link 'Hide'
    end

    login_as(citizen)
    visit debates_path

    expect(page).to have_css('.debate', count: 0)
  end

end