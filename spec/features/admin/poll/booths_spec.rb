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
    booth = create(:poll_booth)

    visit admin_booths_path

    within("#booth_#{booth.id}") do
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

end