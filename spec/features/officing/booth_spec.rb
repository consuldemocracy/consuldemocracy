require "rails_helper"

describe "Booth", :with_frozen_time do
  scenario "Officer with no booth assignments today" do
    officer = create(:poll_officer)

    login_through_form_as_officer(officer.user)

    expect(page).to have_content "You don't have officing shifts today"
  end

  scenario "Officer with booth assignments another day" do
    officer = create(:poll_officer)
    create(:poll_officer_assignment, officer: officer, date: Date.current + 1.day)

    login_through_form_as_officer(officer.user)

    expect(page).to have_content "You don't have officing shifts today"
  end

  scenario "Officer with single booth assignment today" do
    officer = create(:poll_officer)
    poll = create(:poll)

    booth = create(:poll_booth)

    create(:poll_officer_assignment, officer: officer, poll: poll, booth: booth, date: Date.current)

    login_through_form_as_officer(officer.user)

    within("#officing-booth") do
      expect(page).to have_content "You are officing the booth located at #{booth.location}."
    end
  end

  scenario "Officer with multiple booth assignments today" do
    officer = create(:poll_officer)
    poll = create(:poll)

    booth1 = create(:poll_booth)
    booth2 = create(:poll_booth)

    create(:poll_officer_assignment, officer: officer, poll: poll, booth: booth1, date: Date.current)
    create(:poll_officer_assignment, officer: officer, poll: poll, booth: booth2, date: Date.current)

    login_through_form_as_officer(officer.user)

    expect(page).to have_content "Choose your booth"

    select booth2.location, from: "booth_id"
    click_button "Enter"

    within("#officing-booth") do
      expect(page).to have_content "You are officing the booth located at #{booth2.location}."
    end
  end

  scenario "Display single booth for any number of polls" do
    officer = create(:poll_officer)

    booth1 = create(:poll_booth)
    booth2 = create(:poll_booth)

    poll1 = create(:poll)
    poll2 = create(:poll)

    create(:poll_officer_assignment, officer: officer, poll: poll1, booth: booth1, date: Date.current)
    create(:poll_officer_assignment, officer: officer, poll: poll2, booth: booth2, date: Date.current)
    create(:poll_officer_assignment, officer: officer, poll: poll2, booth: booth2, date: Date.current)

    login_through_form_as_officer(officer.user)

    expect(page).to have_content "Choose your booth"

    expect(page).to have_select("booth_id", options: [booth1.location, booth2.location])
  end
end
