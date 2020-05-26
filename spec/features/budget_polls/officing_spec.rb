require "rails_helper"

describe "Budget Poll Officing" do
  scenario "Show sidebar menus if officer has shifts assigned" do
    booth = create(:poll_booth)
    booth_assignment = create(:poll_booth_assignment, booth: booth)
    officer = create(:poll_officer)

    create(:poll_shift, officer: officer, booth: booth, date: Date.current, task: :vote_collection)

    login_as officer.user
    visit officing_root_path

    expect(page).not_to have_content("You don't have officing shifts today")
    expect(page).to have_content("Validate document")
    expect(page).not_to have_content("Total recounts and results")

    create(:poll_shift, officer: officer, booth: booth, date: Date.current, task: :recount_scrutiny)
    create(:poll_officer_assignment, booth_assignment: booth_assignment, officer: officer)

    visit officing_root_path

    expect(page).not_to have_content("You don't have officing shifts today")
    expect(page).to have_content("Validate document")
    expect(page).to have_content("Total recounts and results")
  end

  scenario "Do not show sidebar menus if officer has no shifts assigned" do
    login_as(create(:poll_officer).user)

    visit officing_root_path

    expect(page).to have_content("You don't have officing shifts today")
    expect(page).not_to have_content("Validate document")
    expect(page).not_to have_content("Total recounts and results")
  end
end
