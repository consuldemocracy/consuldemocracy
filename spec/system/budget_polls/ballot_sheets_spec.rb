require "rails_helper"

describe "Poll budget ballot sheets" do
  let(:poll) { create(:poll, :for_budget, ends_at: 1.day.ago) }
  let(:booth) { create(:poll_booth, polls: [poll]) }
  let(:poll_officer) { create(:poll_officer) }

  context "Officing recounts and results view" do
    before do
      create(:poll_shift, :recount_scrutiny_task, officer: poll_officer, booth: booth,
                                                  date: Date.current)
      create(:poll_officer_assignment, officer: poll_officer)

      login_as(poll_officer.user)
      set_officing_booth(booth)
    end

    scenario "Budget polls are visible" do
      visit root_path

      click_link "Menu"
      click_link "Polling officers"

      within("#side_menu") do
        click_link "Total recounts and results"
      end

      within("#poll_#{poll.id}") do
        expect(page).to have_content(poll.name)
        expect(page).to have_content("See ballot sheets list")
        expect(page).to have_content("Add results")
      end
    end
  end

  context "Booth assignment" do
    scenario "Try to access ballot sheets officing without booth assignment" do
      login_as(poll_officer.user)
      visit officing_poll_ballot_sheets_path(poll)

      expect(page).to have_content "You don't have officing shifts today"
    end

    scenario "Access ballot sheets officing with one booth assignment" do
      create(:poll_shift, :recount_scrutiny_task, officer: poll_officer, booth: booth,
                                                  date: Date.current)
      create(:poll_officer_assignment, officer: poll_officer)

      login_as(poll_officer.user)
      set_officing_booth(booth)

      visit officing_poll_ballot_sheets_path(poll)

      expect(page).to have_content poll.name
    end

    scenario "Access ballot sheets officing with multiple booth assignments", :with_frozen_time do
      booth_2 = create(:poll_booth, polls: [poll])
      create(:poll_shift, :recount_scrutiny_task, officer: poll_officer, booth: booth,
                                                  date: Date.current)
      create(:poll_shift, :recount_scrutiny_task, officer: poll_officer, booth: booth_2,
                                                  date: Date.current)
      create(:poll_officer_assignment, officer: poll_officer)
      create(:poll_officer_assignment, officer: poll_officer)

      login_as(poll_officer.user)

      visit officing_poll_ballot_sheets_path(poll)

      expect(page).to have_content "Choose your booth"
    end
  end

  context "Index" do
    before do
      create(:poll_shift, :recount_scrutiny_task, officer: poll_officer, booth: booth,
                                                  date: Date.current)

      login_as(poll_officer.user)
      set_officing_booth(booth)
    end

    scenario "Ballot sheets are listed" do
      officer_assignment = create(:poll_officer_assignment, officer: poll_officer)
      ballot_sheet = create(:poll_ballot_sheet, poll: poll, officer_assignment: officer_assignment)

      visit officing_poll_ballot_sheets_path(poll)

      expect(page).to have_content "Ballot sheet #{ballot_sheet.id}"
    end
  end

  context "New" do
    before do
      create(:poll_shift, :recount_scrutiny_task, officer: poll_officer, booth: booth,
                                                  date: Date.current)
      create(:poll_officer_assignment, officer: poll_officer)

      login_as(poll_officer.user)
      set_officing_booth(booth)
    end

    scenario "Ballot sheet is saved" do
      visit new_officing_poll_ballot_sheet_path(poll)

      select booth.name, from: "officer_assignment_id"
      fill_in "data", with: "1234;5678"
      click_button "Save"

      expect(page).to have_content(/Ballot sheet \d+/)
      expect(page).to have_content(poll_officer.user.name)
      expect(page).to have_content("1234;5678")

      visit officing_poll_ballot_sheets_path(poll)

      expect(page).to have_css "tbody tr", count: 1
    end

    scenario "Ballot sheet is not saved" do
      visit new_officing_poll_ballot_sheet_path(poll)

      select booth.name, from: "officer_assignment_id"
      click_button "Save"

      expect(page).to have_content("CSV data can't be blank")

      visit officing_poll_ballot_sheets_path(poll)

      expect(page).not_to have_css "tbody tr"
    end

    scenario "Shift booth has to be selected" do
      visit new_officing_poll_ballot_sheet_path(poll)

      fill_in "data", with: "1234;5678"
      click_button "Save"

      expect(page).to have_content "Officer assignment can't be blank"
    end
  end

  context "Show" do
    before do
      create(:poll_shift, :recount_scrutiny_task, officer: poll_officer, booth: booth,
                                                  date: Date.current)

      login_as(poll_officer.user)
      set_officing_booth(booth)
    end

    scenario "Ballot sheet information is displayed" do
      officer_assignment = create(:poll_officer_assignment, officer: poll_officer)
      ballot_sheet = create(:poll_ballot_sheet, poll: poll, officer_assignment: officer_assignment)

      visit officing_poll_ballot_sheet_path(poll, ballot_sheet)

      expect(page).to have_content("Ballot sheet #{ballot_sheet.id}")
      expect(page).to have_content(ballot_sheet.author)
      expect(page).to have_content(ballot_sheet.data)
    end
  end
end
