require 'rails_helper'

feature 'Admin polls' do

  background do
    admin = create(:administrator)
    login_as(admin.user)
  end

  scenario 'Index' do
    3.times { create(:poll) }

    visit admin_root_path

    within('#side_menu') do
      click_link "Polls"
    end

    expect(page).to have_css ".poll", count: 3

    Poll.all.each do |poll|
      within("#poll_#{poll.id}") do
        expect(page).to have_content poll.name
#expect(page).to have_content "Status/Dates" - Hardcoded
      end
    end
  end

  scenario 'Show', :focus do
    poll = create(:poll)

    visit admin_polls_path
    click_link poll.name

    expect(page).to have_content poll.name
#expect(page).to have_content "Status/Dates" - Hardcoded
#expect(page).to have_content "REFNUM" - Hardcoded
  end

end