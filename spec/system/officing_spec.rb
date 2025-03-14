require "rails_helper"
require "sessions_helper"

describe "Poll Officing" do
  let(:user) { create(:user) }

  scenario "Access as regular user is not authorized" do
    login_as(user)

    visit officing_root_path

    expect(page).not_to have_current_path(officing_root_path)
    expect(page).to have_current_path(root_path)
    expect(page).to have_content "You do not have permission to access this page"
  end

  scenario "Access as moderator is not authorized" do
    create(:moderator, user: user)
    login_as(user)

    visit officing_root_path

    expect(page).not_to have_current_path(officing_root_path)
    expect(page).to have_current_path(root_path)
    expect(page).to have_content "You do not have permission to access this page"
  end

  scenario "Access as manager is not authorized" do
    create(:manager, user: user)
    login_as(user)

    visit officing_root_path

    expect(page).not_to have_current_path(officing_root_path)
    expect(page).to have_current_path(root_path)
    expect(page).to have_content "You do not have permission to access this page"
  end

  scenario "Access as SDG manager is not authorized" do
    Setting["feature.sdg"] = true
    create(:sdg_manager, user: user)
    login_as(user)

    visit officing_root_path

    expect(page).not_to have_current_path(officing_root_path)
    expect(page).to have_current_path(root_path)
    expect(page).to have_content "You do not have permission to access this page"
  end

  scenario "Access as a valuator is not authorized" do
    create(:valuator, user: user)
    login_as(user)

    visit officing_root_path

    expect(page).not_to have_current_path(officing_root_path)
    expect(page).to have_current_path(root_path)
    expect(page).to have_content "You do not have permission to access this page"
  end

  scenario "Access as an administrator is not authorized" do
    create(:administrator, user: user)
    login_as(user)

    visit officing_root_path

    expect(page).not_to have_current_path(officing_root_path)
    expect(page).to have_current_path(root_path)
    expect(page).to have_content "You do not have permission to access this page"
  end

  scenario "Access as an administrator with poll officer role is authorized" do
    create(:administrator, user: user)
    create(:poll_officer, user: user)
    login_as(user)
    visit root_path

    click_link "Menu"
    click_link "Polling officers"

    expect(page).to have_current_path(officing_root_path)
    expect(page).not_to have_content "You do not have permission to access this page"
  end

  scenario "Access as a poll officer is authorized" do
    create(:poll_officer, user: user)
    login_as(user)
    visit root_path

    click_link "Menu"
    click_link "Polling officers"

    expect(page).to have_current_path(officing_root_path)
    expect(page).to have_css "#officing_menu"
    expect(page).not_to have_link "Polling officers"
    expect(page).not_to have_css "#valuation_menu"
    expect(page).not_to have_css "#admin_menu"
    expect(page).not_to have_css "#moderation_menu"
    expect(page).not_to have_content "You do not have permission to access this page"
  end

  scenario "Officing dashboard available for multiple sessions", :with_frozen_time do
    poll = create(:poll)
    booth = create(:poll_booth)
    booth_assignment = create(:poll_booth_assignment, poll: poll, booth: booth)

    officer1 = create(:poll_officer)
    officer2 = create(:poll_officer)

    create(:poll_shift, officer: officer1, booth: booth, date: Date.current, task: :vote_collection)
    create(:poll_shift, officer: officer2, booth: booth, date: Date.current, task: :vote_collection)

    create(:poll_officer_assignment, booth_assignment: booth_assignment, officer: officer1)
    create(:poll_officer_assignment, booth_assignment: booth_assignment, officer: officer2)

    in_browser(:one) do
      login_as officer1.user
      visit officing_root_path

      expect(page).to have_content "Here you can validate user documents and store voting results"
    end

    in_browser(:two) do
      login_as officer2.user
      visit officing_root_path

      expect(page).to have_content "Here you can validate user documents and store voting results"
    end

    in_browser(:one) do
      visit new_officing_residence_path
      officing_verify_residence(document_number: "12345678Z")

      click_button "Confirm vote"
      expect(page).to have_content "Vote introduced!"
    end

    in_browser(:two) do
      visit new_officing_residence_path
      officing_verify_residence(document_number: "12345678Y")

      click_button "Confirm vote"
      expect(page).to have_content "Vote introduced!"

      visit new_officing_residence_path
      officing_verify_residence(document_number: "12345678Z")

      expect(page).to have_content "Has already participated in this poll"
    end
  end
end
