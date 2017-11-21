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

    shift1 = create(:poll_shift, officer: officer, booth: booth1, date: Time.zone.today)
    shift2 = create(:poll_shift, officer: officer, booth: booth2, date: Time.zone.tomorrow)

    visit new_admin_booth_shift_path(booth1)

    expect(page).to have_css(".shift", count: 1)
    expect(page).to have_content I18n.l(Time.zone.today, format: :long)
    expect(page).to have_content officer.name

    visit new_admin_booth_shift_path(booth2)

    expect(page).to have_css(".shift", count: 1)
    expect(page).to have_content I18n.l(Time.zone.tomorrow, format: :long)
    expect(page).to have_content officer.name
  end

  scenario "Create Vote Collection Shift and Recount & Scrutiny Shift on same date", :js do
    create(:poll)
    create(:poll, :incoming)
    poll = create(:poll, :current)
    booth = create(:poll_booth)
    create(:poll_booth_assignment, poll: poll, booth: booth)
    create(:poll_booth_assignment, poll: create(:poll, :expired), booth: booth)
    officer = create(:poll_officer)
    vote_collection_dates = (Date.current..poll.ends_at.to_date).to_a.map { |date| I18n.l(date, format: :long) }
    recount_scrutiny_dates = (poll.ends_at.to_date..poll.ends_at.to_date + 1.week).to_a.map { |date| I18n.l(date, format: :long) }

    visit available_admin_booths_path

    within("#booth_#{booth.id}") do
      click_link "Manage shifts"
    end

    fill_in "search", with: officer.email
    click_button "Search"
    click_link "Edit shifts"

    expect(page).to have_select('shift_date_vote_collection_date', options: ["Select day", *vote_collection_dates])
    expect(page).not_to have_select('shift_date_recount_scrutiny_date')
    select I18n.l(Date.current, format: :long), from: 'shift_date_vote_collection_date'
    click_button "Add shift"

    expect(page).to have_content "Shift added"

    within("#shifts") do
      expect(page).to have_css(".shift", count: 1)
      expect(page).to have_content(I18n.l(Date.current, format: :long))
      expect(page).to have_content("Collect Votes")
      expect(page).to have_content(officer.name)
    end

    visit available_admin_booths_path

    within("#booth_#{booth.id}") do
      click_link "Manage shifts"
    end

    fill_in "search", with: officer.email
    click_button "Search"
    click_link "Edit shifts"

    select "Recount & Scrutiny", from: 'shift_task'

    expect(page).to have_select('shift_date_recount_scrutiny_date', options: ["Select day", *recount_scrutiny_dates])
    expect(page).not_to have_select('shift_date_vote_collection_date')
    select I18n.l(poll.ends_at.to_date + 4.days, format: :long), from: 'shift_date_recount_scrutiny_date'
    click_button "Add shift"

    expect(page).to have_content "Shift added"

    within("#shifts") do
      expect(page).to have_css(".shift", count: 2)
      expect(page).to have_content(I18n.l(poll.ends_at.to_date + 4.days, format: :long))
      expect(page).to have_content("Recount & Scrutiny")
      expect(page).to have_content(officer.name)
    end
  end

  scenario "Vote Collection Shift and Recount & Scrutiny Shift don't include already assigned dates to officer", :js do
    poll = create(:poll, :current)
    booth = create(:poll_booth)
    assignment = create(:poll_booth_assignment, poll: poll, booth: booth)
    officer = create(:poll_officer)

    shift1 = create(:poll_shift, :vote_collection_task, officer: officer, booth: booth, date: Time.zone.today)
    shift2 = create(:poll_shift, :recount_scrutiny_task, officer: officer, booth: booth, date: Time.zone.tomorrow)

    vote_collection_dates = (Date.current..poll.ends_at.to_date).to_a
                                                                .reject { |date| date == Time.zone.today }
                                                                .map { |date| I18n.l(date, format: :long) }
    recount_scrutiny_dates = (poll.ends_at.to_date..poll.ends_at.to_date + 1.week).to_a
                                                                                  .reject { |date| date == Time.zone.tomorrow }
                                                                                  .map { |date| I18n.l(date, format: :long) }

    visit available_admin_booths_path

    within("#booth_#{booth.id}") do
      click_link "Manage shifts"
    end

    fill_in "search", with: officer.email
    click_button "Search"
    click_link "Edit shifts"

    expect(page).to have_select('shift_date_vote_collection_date', options: ["Select day", *vote_collection_dates])
    select "Recount & Scrutiny", from: 'shift_task'
    expect(page).to have_select('shift_date_recount_scrutiny_date', options: ["Select day", *recount_scrutiny_dates])
  end

  scenario "Error on create", :js do
    poll = create(:poll, :current)
    booth = create(:poll_booth)
    assignment = create(:poll_booth_assignment, poll: poll, booth: booth)
    officer = create(:poll_officer)

    visit available_admin_booths_path

    within("#booth_#{booth.id}") do
      click_link "Manage shifts"
    end

    fill_in "search", with: officer.email
    click_button "Search"
    click_link "Edit shifts"
    click_button "Add shift"

    expect(page).to have_content "A date must be selected"
  end

  scenario "Destroy" do
    poll = create(:poll, :current)
    booth = create(:poll_booth)
    assignment = create(:poll_booth_assignment, poll: poll, booth: booth)
    officer = create(:poll_officer)

    shift = create(:poll_shift, officer: officer, booth: booth)

    visit available_admin_booths_path

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
