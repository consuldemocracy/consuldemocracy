require "rails_helper"

feature "Admin booths assignments" do

  background do
    admin = create(:administrator)
    login_as(admin.user)
  end

  feature "Admin Booth Assignment management" do

    let!(:poll) { create(:poll) }
    let!(:booth) { create(:poll_booth) }

    scenario "List Polls and Booths to manage", :js do
      second_poll = create(:poll)
      second_booth = create(:poll_booth)

      visit booth_assignments_admin_polls_path

      expect(page).to have_content(poll.name)
      expect(page).to have_content(second_poll.name)

      within("#poll_#{second_poll.id}") do
        click_link "Manage assignments"
      end

      expect(page).to have_content "Assignments for poll "#{second_poll.name}""

      expect(page).to have_content(booth.name)
      expect(page).to have_content(second_booth.name)
    end

    scenario "Assign booth to poll", :js do
      visit admin_poll_path(poll)
      within("#poll-resources") do
        click_link "Booths (0)"
      end

      expect(page).to have_content "There are no booths assigned to this poll."
      expect(page).not_to have_content booth.name

      fill_in "search-booths", with: booth.name
      click_button "Search"
      expect(page).to have_content(booth.name)

      visit manage_admin_poll_booth_assignments_path(poll)

      expect(page).to have_content "Assignments for poll "#{poll.name}""

      within("#poll_booth_#{booth.id}") do
        expect(page).to have_content(booth.name)
        expect(page).to have_content "Unassigned"

        click_link "Assign booth"

        expect(page).not_to have_content "Unassigned"
        expect(page).to have_content "Assigned"
        expect(page).to have_link "Unassign booth"
      end

      visit admin_poll_path(poll)
      within("#poll-resources") do
        click_link "Booths (1)"
      end

      expect(page).not_to have_content "There are no booths assigned to this poll."
      expect(page).to have_content booth.name
    end

    scenario "Unassign booth from poll", :js do
      assignment = create(:poll_booth_assignment, poll: poll, booth: booth)

      visit admin_poll_path(poll)
      within("#poll-resources") do
        click_link "Booths (1)"
      end

      expect(page).not_to have_content "There are no booths assigned to this poll."
      expect(page).to have_content booth.name

      fill_in "search-booths", with: booth.name
      click_button "Search"
      expect(page).to have_content(booth.name)

      visit manage_admin_poll_booth_assignments_path(poll)

      expect(page).to have_content "Assignments for poll "#{poll.name}""

      within("#poll_booth_#{booth.id}") do
        expect(page).to have_content(booth.name)
        expect(page).to have_content "Assigned"

        click_link "Unassign booth"

        expect(page).to have_content "Unassigned"
        expect(page).not_to have_content "Assigned"
        expect(page).to have_link "Assign booth"
      end

      visit admin_poll_path(poll)
      within("#poll-resources") do
        click_link "Booths (0)"
      end

      expect(page).to have_content "There are no booths assigned to this poll."
      expect(page).not_to have_content booth.name
    end

    scenario "Unassing booth whith associated shifts", :js do
      assignment = create(:poll_booth_assignment, poll: poll, booth: booth)
      officer = create(:poll_officer)
      create(:poll_officer_assignment, officer: officer, booth_assignment: assignment)
      create(:poll_shift, booth: booth, officer: officer)

      visit manage_admin_poll_booth_assignments_path(poll)

      within("#poll_booth_#{booth.id}") do
        expect(page).to have_content(booth.name)
        expect(page).to have_content "Assigned"

        accept_confirm { click_link "Unassign booth" }

        expect(page).to have_content "Unassigned"
        expect(page).not_to have_content "Assigned"
        expect(page).to have_link "Assign booth"
      end
    end

    scenario "Cannot unassing booth if poll is expired" do
      poll_expired = create(:poll, :expired)
      create(:poll_booth_assignment, poll: poll_expired, booth: booth)

      visit manage_admin_poll_booth_assignments_path(poll_expired)

      within("#poll_booth_#{booth.id}") do
        expect(page).to have_content(booth.name)
        expect(page).to have_content "Assigned"

        expect(page).not_to have_link "Unassign booth"
      end

    end
  end

  feature "Show" do
    scenario "Lists all assigned poll officers" do
      poll = create(:poll)
      booth = create(:poll_booth)
      booth_assignment = create(:poll_booth_assignment, poll: poll, booth: booth)
      officer_assignment = create(:poll_officer_assignment, booth_assignment: booth_assignment)
      officer = officer_assignment.officer

      booth_assignment_2 = create(:poll_booth_assignment, poll: poll)
      officer_assignment_2 = create(:poll_officer_assignment, booth_assignment: booth_assignment_2)
      officer_2 = officer_assignment_2.officer

      visit admin_poll_path(poll)
      click_link "Booths (2)"

      within("#assigned_booths_list") { click_link booth.name }

      click_link "Officers"
      within("#officers_list") do
        expect(page).to have_content officer.name
        expect(page).not_to have_content officer_2.name
      end
    end

    scenario "Lists all recounts for the booth assignment" do
      poll = create(:poll, starts_at: 2.weeks.ago, ends_at: 1.week.ago)
      booth = create(:poll_booth)
      booth_assignment = create(:poll_booth_assignment, poll: poll, booth: booth)
      officer_assignment_1 = create(:poll_officer_assignment, booth_assignment: booth_assignment, date: poll.starts_at)
      officer_assignment_2 = create(:poll_officer_assignment, booth_assignment: booth_assignment, date: poll.ends_at)
      final_officer_assignment = create(:poll_officer_assignment, :final, booth_assignment: booth_assignment, date: poll.ends_at)

      create(:poll_voter, poll: poll, booth_assignment: booth_assignment, created_at: poll.starts_at.to_date)
      create(:poll_voter, poll: poll, booth_assignment: booth_assignment, created_at: poll.ends_at.to_date)

      booth_assignment_2 = create(:poll_booth_assignment, poll: poll)

      visit admin_poll_path(poll)
      click_link "Booths (2)"

      within("#assigned_booths_list") { click_link booth.name }

      click_link "Recounts"

      within("#totals") do
        within("#total_system") { expect(page).to have_content "2" }
      end

      within("#recounts_list") do
        within("#recounting_#{poll.starts_at.to_date.strftime('%Y%m%d')}") do
          expect(page).to have_content 1
        end
        within("#recounting_#{(poll.ends_at.to_date - 5.days).strftime('%Y%m%d')}") do
          expect(page).to have_content "-"
        end
        within("#recounting_#{poll.ends_at.to_date.strftime('%Y%m%d')}") do
          expect(page).to have_content 1
        end
      end
    end

    scenario "Results for a booth assignment" do
      poll = create(:poll)
      booth_assignment = create(:poll_booth_assignment, poll: poll)
      other_booth_assignment = create(:poll_booth_assignment, poll: poll)

      question_1 = create(:poll_question, poll: poll)
      create(:poll_question_answer, title: "Yes", question: question_1)
      create(:poll_question_answer, title: "No", question: question_1)

      question_2 = create(:poll_question, poll: poll)
      create(:poll_question_answer, title: "Today", question: question_2)
      create(:poll_question_answer, title: "Tomorrow", question: question_2)

      create(:poll_partial_result,
              booth_assignment: booth_assignment,
              question: question_1,
              answer: "Yes",
              amount: 11)

      create(:poll_partial_result,
              booth_assignment: booth_assignment,
              question: question_1,
              answer: "No",
              amount: 4)

      create(:poll_partial_result,
              booth_assignment: booth_assignment,
              question: question_2,
              answer: "Today",
              amount: 5)

      create(:poll_partial_result,
              booth_assignment: booth_assignment,
              question: question_2,
              answer: "Tomorrow",
              amount: 6)

      create(:poll_partial_result,
              booth_assignment: other_booth_assignment,
              question: question_1,
              answer: "Yes",
              amount: 9999)

      create(:poll_recount,
             booth_assignment: booth_assignment,
             white_amount: 21,
             null_amount: 44,
             total_amount: 66)

      create(:poll_recount,
             booth_assignment: other_booth_assignment,
             white_amount: 999,
             null_amount: 999,
             total_amount: 999)

      visit admin_poll_booth_assignment_path(poll, booth_assignment)

      click_link "Results"

      expect(page).to have_content(question_1.title)

      within("#question_#{question_1.id}_0_result") do
        expect(page).to have_content("Yes")
        expect(page).to have_content(11)
      end

      within("#question_#{question_1.id}_1_result") do
        expect(page).to have_content("No")
        expect(page).to have_content(4)
      end

      expect(page).to have_content(question_2.title)

      within("#question_#{question_2.id}_0_result") do
        expect(page).to have_content("Today")
        expect(page).to have_content(5)
      end

      within("#question_#{question_2.id}_1_result") do
        expect(page).to have_content("Tomorrow")
        expect(page).to have_content(6)
      end

      within("#white_results") { expect(page).to have_content("21") }
      within("#null_results") { expect(page).to have_content("44") }
      within("#total_results") { expect(page).to have_content("66") }
    end

    scenario "No results" do
      poll = create(:poll)
      booth_assignment = create(:poll_booth_assignment, poll: poll)

      visit admin_poll_booth_assignment_path(poll, booth_assignment)

      click_link "Results"

      expect(page).to have_content "There are no results"
    end

  end
end
