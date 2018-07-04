require 'rails_helper'

feature 'Budget Poll Officing' do

  scenario 'Show sidebar menu if officer has shifts assigned' do
    poll = create(:poll)
    booth = create(:poll_booth)
    booth_assignment = create(:poll_booth_assignment, poll: poll, booth: booth)

    user = create(:user)
    officer = create(:poll_officer, user: user)

    create(:poll_shift, officer: officer, booth: booth, date: Date.current, task: :recount_scrutiny)

    officer_assignment = create(:poll_officer_assignment,
                                 booth_assignment: booth_assignment,
                                 officer: officer)

    login_as user
    visit officing_root_path

    expect(page).not_to have_content("You don't have officing shifts today")
    expect(page).to have_content("Validate document")
    expect(page).to have_content("Total recounts and results")
  end

  scenario 'Do not show sidebar menu if officer has no shifts assigned' do
    user = create(:user)
    officer = create(:poll_officer, user: user)

    login_as user
    visit officing_root_path

    expect(page).to have_content("You don't have officing shifts today")
    expect(page).not_to have_content("Validate document")
    expect(page).not_to have_content("Total recounts and results")
  end

end