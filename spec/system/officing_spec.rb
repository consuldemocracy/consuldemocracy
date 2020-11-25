require "rails_helper"
require "sessions_helper"

describe "Poll Officing" do
  let(:user) { create(:user) }

  scenario "Access as regular user is not authorized" do
    login_as(user)
    visit root_path

    expect(page).not_to have_link("Polling officers")
    visit officing_root_path

    expect(page).not_to have_current_path(officing_root_path)
    expect(page).to have_current_path(root_path)
    expect(page).to have_content "You do not have permission to access this page"
  end

  scenario "Access as moderator is not authorized" do
    create(:moderator, user: user)
    login_as(user)
    visit root_path

    expect(page).not_to have_link("Polling officers")
    visit officing_root_path

    expect(page).not_to have_current_path(officing_root_path)
    expect(page).to have_current_path(root_path)
    expect(page).to have_content "You do not have permission to access this page"
  end

  scenario "Access as manager is not authorized" do
    create(:manager, user: user)
    login_as(user)
    visit root_path

    expect(page).not_to have_link("Polling officers")
    visit officing_root_path

    expect(page).not_to have_current_path(officing_root_path)
    expect(page).to have_current_path(root_path)
    expect(page).to have_content "You do not have permission to access this page"
  end

  scenario "Access as SDG manager is not authorized", :js do
    create(:sdg_manager, user: user)
    login_as(user)
    visit root_path

    expect(page).not_to have_link("Polling officers")

    visit officing_root_path

    expect(page).not_to have_current_path(officing_root_path)
    expect(page).to have_current_path(root_path)
    expect(page).to have_content "You do not have permission to access this page"
  end

  scenario "Access as a valuator is not authorized" do
    create(:valuator, user: user)
    login_as(user)
    visit root_path

    expect(page).not_to have_link("Polling officers")
    visit officing_root_path

    expect(page).not_to have_current_path(officing_root_path)
    expect(page).to have_current_path(root_path)
    expect(page).to have_content "You do not have permission to access this page"
  end

  scenario "Access as an administrator is not authorized" do
    create(:administrator, user: user)
    create(:poll)
    login_as(user)
    visit root_path

    expect(page).not_to have_link("Polling officers")
    visit officing_root_path

    expect(page).not_to have_current_path(officing_root_path)
    expect(page).to have_current_path(root_path)
    expect(page).to have_content "You do not have permission to access this page"
  end

  scenario "Access as an administrator with poll officer role is authorized" do
    create(:administrator, user: user)
    create(:poll_officer, user: user)
    create(:poll)
    login_as(user)
    visit root_path

    expect(page).to have_link("Polling officers")
    click_on "Polling officers"

    expect(page).to have_current_path(officing_root_path)
    expect(page).not_to have_content "You do not have permission to access this page"
  end

  scenario "Access as an poll officer is authorized" do
    create(:poll_officer, user: user)
    create(:poll)
    login_as(user)
    visit root_path

    expect(page).to have_link("Polling officers")
    click_on "Polling officers"

    expect(page).to have_current_path(officing_root_path)
    expect(page).not_to have_content "You do not have permission to access this page"
  end

  scenario "Poll officer access links" do
    create(:poll)
    create(:poll_officer, user: user)
    login_as(user)
    visit root_path

    expect(page).to have_link("Polling officers")
    expect(page).not_to have_link("Valuation")
    expect(page).not_to have_link("Administration")
    expect(page).not_to have_link("Moderation")
  end

  scenario "Officing dashboard" do
    create(:poll_officer, user: user)
    create(:poll)
    login_as(user)
    visit root_path

    click_link "Polling officers"

    expect(page).to have_current_path(officing_root_path)
    expect(page).to have_css("#officing_menu")
    expect(page).not_to have_link("Polling officers")
    expect(page).not_to have_css("#valuation_menu")
    expect(page).not_to have_css("#admin_menu")
    expect(page).not_to have_css("#moderation_menu")
  end

  scenario "Officing dashboard available for multiple sessions", :js, :with_frozen_time do
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
    end

    in_browser(:two) do
      login_as officer2.user
      visit officing_root_path
    end

    in_browser(:one) do
      expect(page).to have_content("Here you can validate user documents and store voting results")

      visit new_officing_residence_path
      expect(page).to have_selector("#residence_document_type")

      select "DNI", from: "residence_document_type"
      fill_in "residence_document_number", with: "12345678Z"
      fill_in "residence_year_of_birth", with: "1980"
      click_button "Validate document"
      expect(page).to have_content "Document verified with Census"
      click_button "Confirm vote"
      expect(page).to have_content "Vote introduced!"
      expect(Poll::Voter.where(document_number: "12345678Z", poll_id: poll, origin: "booth", officer_id: officer1).count).to be(1)

      visit final_officing_polls_path
      expect(page).to have_content("Polls ready for final recounting")
    end

    in_browser(:two) do
      expect(page).to have_content("Here you can validate user documents and store voting results")

      visit new_officing_residence_path
      expect(page).to have_selector("#residence_document_type")

      select "DNI", from: "residence_document_type"
      fill_in "residence_document_number", with: "12345678Y"
      fill_in "residence_year_of_birth", with: "1980"
      click_button "Validate document"
      expect(page).to have_content "Document verified with Census"
      click_button "Confirm vote"
      expect(page).to have_content "Vote introduced!"
      expect(Poll::Voter.where(document_number: "12345678Y", poll_id: poll, origin: "booth", officer_id: officer2).count).to be(1)

      visit final_officing_polls_path
      expect(page).to have_content("Polls ready for final recounting")
    end
  end
end
