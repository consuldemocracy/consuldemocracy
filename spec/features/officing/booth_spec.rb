require 'rails_helper'

feature 'Booth' do

  scenario "Officer with no booth assignments today" do
    officer = create(:poll_officer)

    login_through_form_as(officer.user)

    expect(page).to have_content "You don't have officing shifts today"
  end

  scenario "Officer with booth assignments another day" do
    officer = create(:poll_officer)
    create(:poll_officer_assignment, officer: officer, date: 1.day.from_now)

    login_through_form_as(officer.user)

    expect(page).to have_content "You don't have officing shifts today"
  end

  scenario 'Officer with single booth assignment today' do
    officer = create(:poll_officer)
    poll = create(:poll)

    booth = create(:poll_booth)

    booth_assignment = create(:poll_booth_assignment, poll: poll, booth: booth)
    create(:poll_officer_assignment, officer: officer, booth_assignment: booth_assignment, date: Date.today)

    login_through_form_as(officer.user)

    expect(page).to have_content "You are officing booth #{booth.name}"
  end

  scenario 'Officer with multiple booth assignments today' do
    officer = create(:poll_officer)
    poll = create(:poll)

    booth1 = create(:poll_booth)
    booth2 = create(:poll_booth)

    ba1 = create(:poll_booth_assignment, poll: poll, booth: booth1)
    ba2 = create(:poll_booth_assignment, poll: poll, booth: booth2)

    create(:poll_officer_assignment, officer: officer, booth_assignment: ba1, date: Date.today)
    create(:poll_officer_assignment, officer: officer, booth_assignment: ba2, date: Date.today)

    login_through_form_as(officer.user)

    expect(page).to have_content 'You have been signed in successfully.'
    expect(page).to have_content 'Choose your booth'

    select booth2.name, from: 'booth_id'
    click_button 'Enter'

    expect(page).to have_content "You are officing booth #{booth2.name}"
  end

end
