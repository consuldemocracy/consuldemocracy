require 'rails_helper'

feature 'Admin booths' do

  background do
    admin = create(:administrator)
    login_as(admin.user)
  end

  scenario 'Index empty' do
    visit admin_root_path

    within('#side_menu') do
      click_link "Booths location"
    end

    expect(page).to have_content "There are no booths"
  end

  scenario 'Index' do
    3.times { create(:poll_booth) }

    visit admin_root_path

    within('#side_menu') do
      click_link "Booths location"
    end

    booths = Poll::Booth.all
    booths.each do |booth|
      within("#booth_#{booth.id}") do
        expect(page).to have_content booth.name
        expect(page).to have_content booth.location
      end
    end
    expect(page).to_not have_content "There are no booths"
  end

  scenario "Available" do
    booth_for_current_poll  = create(:poll_booth)
    booth_for_incoming_poll = create(:poll_booth)
    booth_for_expired_poll  = create(:poll_booth)

    current_poll  = create(:poll, :current)
    incoming_poll = create(:poll, :incoming)
    expired_poll  = create(:poll, :expired)

    create(:poll_booth_assignment, poll: current_poll,  booth: booth_for_current_poll)
    create(:poll_booth_assignment, poll: incoming_poll, booth: booth_for_incoming_poll)
    create(:poll_booth_assignment, poll: expired_poll,  booth: booth_for_expired_poll)

    visit admin_root_path

    within('#side_menu') do
      click_link "Manage shifts"
    end

    expect(page).to have_css(".booth", count: 2)

    expect(page).to have_content booth_for_current_poll.name
    expect(page).to have_content booth_for_incoming_poll.name
    expect(page).to_not have_content booth_for_expired_poll.name
    expect(page).to_not have_link "Edit booth"
  end

  scenario 'Show' do
    booth = create(:poll_booth)

    visit admin_booths_path

    expect(page).to have_content booth.name
    expect(page).to have_content booth.location
  end

  scenario "Create" do
    visit admin_booths_path
    click_link "Add booth"

    fill_in "poll_booth_name", with: "Upcoming booth"
    fill_in "poll_booth_location", with: "39th Street, number 2, ground floor"
    click_button "Create booth"

    expect(page).to have_content "Booth created successfully"

    visit admin_booths_path
    expect(page).to have_content "Upcoming booth"
    expect(page).to have_content "39th Street, number 2, ground floor"
  end

  scenario "Edit" do
    poll = create(:poll, :current)
    booth = create(:poll_booth)
    assignment = create(:poll_booth_assignment, poll: poll, booth: booth)

    visit admin_booths_path

    within("#booth_#{booth.id}") do
      expect(page).to_not have_link "Manage shifts"
      click_link "Edit booth"
    end

    fill_in "poll_booth_name", with: "Next booth"
    fill_in "poll_booth_location", with: "40th Street, number 1, firts floor"
    click_button "Update booth"

    expect(page).to have_content "Booth updated successfully"

    visit admin_booths_path

    within("#booth_#{booth.id}") do
      expect(page).to have_content "Next booth"
      expect(page).to have_content "40th Street, number 1, firts floor"
    end
  end

  scenario "Back link go back to available list when manage shifts" do
    poll = create(:poll, :current)
    booth = create(:poll_booth)
    assignment = create(:poll_booth_assignment, poll: poll, booth: booth)

    visit available_admin_booths_path

    within("#booth_#{booth.id}") do
      click_link "Manage shifts"
    end

    click_link "Go back"
    expect(current_path).to eq(available_admin_booths_path)
  end
end
