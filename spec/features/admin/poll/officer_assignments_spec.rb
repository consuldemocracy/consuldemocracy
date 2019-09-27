require "rails_helper"

describe "Officer Assignments" do

  before do
    admin = create(:administrator)
    login_as(admin.user)
  end

  scenario "Index" do
    poll = create(:poll)

    officer1 = create(:poll_officer, name: "Bubbles")
    officer2 = create(:poll_officer, name: "Blossom")
    officer3 = create(:poll_officer, name: "Buttercup")

    officer_assignment = create(:poll_officer_assignment, poll: poll, officer: officer1)
    officer_assignment_2 = create(:poll_officer_assignment, poll: poll, officer: officer2)

    visit admin_poll_path(poll)

    click_link "Officers (2)"

    within("#officer_assignments") do
      expect(page).to have_content "Bubbles"
      expect(page).to have_content "Blossom"
      expect(page).not_to have_content "Buttercup"
    end
  end

  scenario "Search", :js do
    poll = create(:poll)

    officer1 = create(:poll_officer, name: "John Snow")
    officer2 = create(:poll_officer, name: "John Silver")
    officer3 = create(:poll_officer, name: "John Edwards")

    officer_assignment = create(:poll_officer_assignment, poll: poll, officer: officer1)
    officer_assignment_2 = create(:poll_officer_assignment, poll: poll, officer: officer2)

    visit admin_poll_path(poll)

    click_link "Officers (2)"

    fill_in "search-officers", with: "John"
    click_button "Search"

    within("#search-officers-results") do
      expect(page).to have_content "John Snow"
      expect(page).to have_content "John Silver"
      expect(page).not_to have_content "John Edwards"
    end
  end

end
