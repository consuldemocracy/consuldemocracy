require 'rails_helper'

feature 'Admin booths assignments' do

  background do
    admin = create(:administrator)
    login_as(admin.user)
  end

  scenario 'Assign booth to poll', :js do
    poll = create(:poll)
    booth = create(:poll_booth)

    visit admin_poll_path(poll)
    within('#poll-resources') do
      click_link 'Booths (0)'
    end

    expect(page).to have_content 'There are no booths assigned to this poll.'

    fill_in 'search-booths', with: booth.name
    click_button 'Search'

    within('#search-booths-results') do
      click_link 'Assign booth'
    end

    expect(page).to have_content 'Booth assigned'

    visit admin_poll_path(poll)
    within('#poll-resources') do
      click_link 'Booths (1)'
    end

    expect(page).to_not have_content 'There are no booths assigned to this poll.'
    expect(page).to have_content booth.name
  end

  scenario 'remove booth from poll', :js do
    poll = create(:poll)
    booth = create(:poll_booth)
    create(:poll_booth_assignment, poll: poll, booth: booth)

    visit admin_poll_path(poll)
    within('#poll-resources') do
      click_link 'Booths (1)'
    end

    expect(page).to_not have_content 'There are no booths assigned to this poll.'
    expect(page).to have_content booth.name

    within("#booth_#{booth.id}") do
      click_link 'Remove booth from poll'
    end

    expect(page).to have_content 'Booth not assigned anymore'

    visit admin_poll_path(poll)
    within('#poll-resources') do
      click_link 'Booths (0)'
    end

    expect(page).to have_content 'There are no booths assigned to this poll.'
    expect(page).to_not have_content booth.name
  end
end