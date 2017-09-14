require 'rails_helper'

feature 'Admin shifts' do

  background do
    admin = create(:administrator)
    login_as(admin.user)
  end

  scenario "Show" do
    poll = create(:poll)
    officer = create(:poll_officer)

    booth1 = create(:poll_booth)
    booth2 = create(:poll_booth)

    shift1 = create(:poll_shift, officer: officer, booth: booth1, date: Date.today)
    shift2 = create(:poll_shift, officer: officer, booth: booth2, date: Date.tomorrow)

    visit new_admin_booth_shift_path(booth1)

    expect(page).to have_css(".shift", count: 1)
    expect(page).to have_content I18n.l(Date.today, format: :long)
    expect(page).to have_content officer.name

    visit new_admin_booth_shift_path(booth2)

    expect(page).to have_css(".shift", count: 1)
    expect(page).to have_content I18n.l(Date.tomorrow, format: :long)
    expect(page).to have_content officer.name
  end

  scenario "Create", :js do
    poll = create(:poll)
    booth = create(:poll_booth)
    officer = create(:poll_officer)

    visit admin_booths_path

    within("#booth_#{booth.id}") do
      click_link "Manage shifts"
    end

    fill_in "search", with: officer.email
    click_button "Search"
    click_link "Edit shifts"

    select I18n.l(poll.starts_at.to_date, format: :long), from: 'shift_date'
    click_button "Add shift"

    expect(page).to have_content "Shift added"

    within("#shifts") do
      expect(page).to have_css(".shift", count: 1)
      expect(page).to have_content(I18n.l(poll.starts_at.to_date, format: :long))
      expect(page).to have_content(officer.name)
    end
  end

  scenario "Erros on create", :js do
    poll = create(:poll)
    booth = create(:poll_booth)
    officer = create(:poll_officer)

    visit admin_booths_path

    within("#booth_#{booth.id}") do
      click_link "Manage shifts"
    end

    fill_in "search", with: officer.email
    click_button "Search"
    click_link "Edit shifts"
    click_button "Add shift"

    expect(page).to have_content "can't be blank"
  end

  scenario "Destroy" do
    poll = create(:poll)
    booth = create(:poll_booth)
    officer = create(:poll_officer)

    shift = create(:poll_shift, officer: officer, booth: booth)

    visit admin_booths_path

    within("#booth_#{booth.id}") do
      click_link "Manage shifts"
    end

    expect(page).to have_css(".shift", count: 1)
    within("#shift_#{shift.id}") do
      click_link "Remove"
    end

    expect(page).to have_content "Shift removed"
    expect(page).to have_css(".shift", count: 0)
  end

  scenario "Destroy an officer" do
    poll = create(:poll)
    booth = create(:poll_booth)
    officer = create(:poll_officer)

    shift = create(:poll_shift, officer: officer, booth: booth)
    officer.destroy

    visit new_admin_booth_shift_path(booth)

    expect(page).to have_css(".shift", count: 1)
    expect(page).to have_content(officer.name)
  end

  scenario "Empty" do
    poll = create(:poll)
    booth = create(:poll_booth)

    visit new_admin_booth_shift_path(booth)

    expect(page).to have_content "This booth has no shifts"
  end

end
