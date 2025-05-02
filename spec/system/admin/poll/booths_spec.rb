require "rails_helper"

describe "Admin booths", :admin do
  scenario "Index empty" do
    visit admin_root_path

    within("#side_menu") do
      click_button "Voting booths"
      click_link "Booths location"
    end

    expect(page).to have_content "There are no active booths for any upcoming poll."
  end

  scenario "Index" do
    booths = 3.times.map { create(:poll_booth) }

    visit admin_root_path

    within("#side_menu") do
      click_button "Voting booths"
      click_link "Booths location"
    end

    booths.each do |booth|
      within("#booth_#{booth.id}") do
        expect(page).to have_content booth.name
        expect(page).to have_content booth.location
      end
    end
    expect(page).not_to have_content "There are no booths"
  end

  scenario "Available" do
    booth_for_current_poll = create(:poll_booth, polls: [create(:poll)])
    booth_for_expired_poll = create(:poll_booth, polls: [create(:poll, :expired)])

    visit admin_root_path

    within("#side_menu") do
      click_button "Voting booths"
      click_link "Shifts Assignments"
    end

    expect(page).to have_css(".booth", count: 1)

    expect(page).to have_content booth_for_current_poll.name
    expect(page).not_to have_content booth_for_expired_poll.name
    expect(page).not_to have_link "Edit"
  end

  scenario "Show" do
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

    refresh

    expect(page).not_to have_content "Booth created successfully"
    expect(page).to have_content "Upcoming booth"
    expect(page).to have_content "39th Street, number 2, ground floor"
  end

  scenario "Edit" do
    poll = create(:poll)
    booth = create(:poll_booth, polls: [poll])

    visit admin_booths_path

    within("#booth_#{booth.id}") do
      expect(page).not_to have_link "Shifts Assignments"
      click_link "Edit"
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
    poll = create(:poll)
    booth = create(:poll_booth, polls: [poll])

    visit available_admin_booths_path

    within("#booth_#{booth.id}") do
      click_link "Shifts Assignments"
    end

    click_link "Go back"
    expect(page).to have_current_path(available_admin_booths_path)
  end

  scenario "Search" do
    create(:poll_booth, name: "Consulting Detective", location: "221B Baker Street")
    create(:poll_booth, name: "World's Greatest Detective", location: "Gotham")

    visit admin_booths_path

    expect(page).to have_css ".booth", count: 2

    fill_in "search", with: "Consulting"
    click_button "Search"
    expect(page).not_to have_content "Greatest Detective"
    expect(page).to have_content "Consulting Detective"
    expect(page).to have_css ".booth", count: 1

    fill_in "search", with: "Gotham"
    click_button "Search"
    expect(page).not_to have_content "Consulting Detective"
    expect(page).to have_content "Greatest Detective"
    expect(page).to have_css ".booth", count: 1

    fill_in "search", with: "Wrong search criteria"
    click_button "Search"
    expect(page).to have_content "There are no active booths for any upcoming poll."
  end
end
