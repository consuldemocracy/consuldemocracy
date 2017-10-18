require 'rails_helper'

feature 'Officer Assignments' do

  background do
    admin = create(:administrator)
    login_as(admin.user)
  end

  scenario "Index" do
    poll = create(:poll)
    booth = create(:poll_booth)

    officer1 = create(:poll_officer)
    officer2 = create(:poll_officer)
    officer3 = create(:poll_officer)

    booth_assignment = create(:poll_booth_assignment, poll: poll, booth: booth)
    officer_assignment = create(:poll_officer_assignment, booth_assignment: booth_assignment, officer: officer1)

    booth_assignment_2 = create(:poll_booth_assignment, poll: poll)
    officer_assignment_2 = create(:poll_officer_assignment, booth_assignment: booth_assignment_2, officer: officer2)

    visit admin_poll_path(poll)

    click_link 'Officers (2)'

    within('#officer_assignments') do
      expect(page).to have_content officer1.name
      expect(page).to have_content officer2.name
      expect(page).to_not have_content officer3.name
    end
  end

  scenario "Search", :js do
    poll = create(:poll)
    booth = create(:poll_booth)

    user1 = create(:user, username: "John Snow")
    user2 = create(:user, username: "John Silver")
    user3 = create(:user, username: "John Edwards")

    officer1 = create(:poll_officer, user: user1)
    officer2 = create(:poll_officer, user: user2)
    officer3 = create(:poll_officer, user: user3)

    booth_assignment = create(:poll_booth_assignment, poll: poll, booth: booth)
    officer_assignment = create(:poll_officer_assignment, booth_assignment: booth_assignment, officer: officer1)

    booth_assignment_2 = create(:poll_booth_assignment, poll: poll)
    officer_assignment_2 = create(:poll_officer_assignment, booth_assignment: booth_assignment_2, officer: officer2)

    visit admin_poll_path(poll)

    click_link 'Officers (2)'

    fill_in "search-officers", with: "John"
    click_button "Search"

    within('#search-officers-results') do
      expect(page).to have_content officer1.name
      expect(page).to have_content officer2.name
      expect(page).to_not have_content officer3.name
    end
  end

end