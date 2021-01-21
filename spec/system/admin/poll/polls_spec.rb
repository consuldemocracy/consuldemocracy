require "rails_helper"

describe "Admin polls", :admin do
  scenario "Disabled with a feature flag" do
    Setting["process.polls"] = nil
    expect { visit admin_polls_path }.to raise_exception(FeatureFlags::FeatureDisabled)
  end

  scenario "Index empty", :js do
    visit admin_root_path

    click_link "Polls"

    expect(page).to have_content "There are no polls"
  end

  scenario "Index show polls list order by starts at date", :js do
    poll_1 = create(:poll, name: "Poll first",  starts_at: 15.days.ago)
    poll_2 = create(:poll, name: "Poll second", starts_at: 1.month.ago)
    poll_3 = create(:poll, name: "Poll third",  starts_at: 2.days.ago)

    visit admin_root_path

    click_link "Polls"

    expect(page).to have_content "List of polls"
    expect(page).to have_css ".poll", count: 3

    polls = Poll.all
    polls.each do |poll|
      within("#poll_#{poll.id}") do
        expect(page).to have_content poll.name
      end
    end

    expect(poll_3.name).to appear_before(poll_1.name)
    expect(poll_1.name).to appear_before(poll_2.name)
    expect(page).not_to have_content "There are no polls"
  end

  scenario "Index do not show polls created by users from proposals dashboard" do
    create(:poll, name: "Poll created by admin")
    create(:poll, name: "Poll from user's proposal", related_type: "Proposal")

    visit admin_polls_path

    expect(page).to have_css ".poll", count: 1
    expect(page).to have_content "Poll created by admin"
    expect(page).not_to have_content "Poll from user's proposal"
  end

  scenario "Show" do
    poll = create(:poll)

    visit admin_polls_path
    click_link "Configure"

    expect(page).to have_content poll.name
  end

  scenario "Create" do
    visit admin_polls_path
    click_link "Create poll"

    start_date = 1.week.from_now
    end_date = 2.weeks.from_now

    fill_in "Name", with: "Upcoming poll"
    fill_in "poll_starts_at", with: start_date.strftime("%d/%m/%Y")
    fill_in "poll_ends_at", with: end_date.strftime("%d/%m/%Y")
    fill_in "Summary", with: "Upcoming poll's summary. This poll..."
    fill_in "Description", with: "Upcomming poll's description. This poll..."

    expect(page).not_to have_css("#poll_results_enabled")
    expect(page).not_to have_css("#poll_stats_enabled")

    click_button "Create poll"

    expect(page).to have_content "Poll created successfully"
    expect(page).to have_content "Upcoming poll"
    expect(page).to have_content I18n.l(start_date.to_date)
    expect(page).to have_content I18n.l(end_date.to_date)
    expect(Poll.last.slug).to eq "#{Poll.last.name.to_s.parameterize}"
  end

  scenario "Edit" do
    poll = create(:poll, :with_image)

    visit admin_poll_path(poll)
    click_link "Edit poll"

    end_date = 1.year.from_now

    expect(page).to have_css("img[alt='#{poll.image.title}']")

    fill_in "Name", with: "Next Poll"
    fill_in "poll_ends_at", with: end_date.strftime("%d/%m/%Y")

    click_button "Update poll"

    expect(page).to have_content "Poll updated successfully"
    expect(page).to have_content "Next Poll"
    expect(page).to have_content I18n.l(end_date.to_date)
  end

  scenario "Edit from index" do
    poll = create(:poll)
    visit admin_polls_path

    within("#poll_#{poll.id}") do
      click_link "Edit"
    end

    expect(page).to have_current_path(edit_admin_poll_path(poll))
  end

  context "Destroy" do
    scenario "Can destroy poll without questions", :js do
      poll = create(:poll)

      visit admin_polls_path

      within("#poll_#{poll.id}") do
        accept_confirm { click_link "Delete" }
      end

      expect(page).to have_content("Poll deleted successfully")
      expect(page).to have_content("There are no polls.")
    end

    scenario "Can destroy poll with questions and answers", :js do
      poll = create(:poll, name: "Do you support CONSUL?")
      create(:poll_question, :yes_no, poll: poll)

      visit admin_polls_path

      within(".poll", text: "Do you support CONSUL?") do
        accept_confirm { click_link "Delete" }
      end

      expect(page).to     have_content("Poll deleted successfully")
      expect(page).not_to have_content("Do you support CONSUL?")

      expect(Poll::Question.count).to eq(0)
      expect(Poll::Question::Answer.count).to eq(0)
    end

    scenario "Can destroy polls with answers including videos", :js do
      poll = create(:poll, name: "Do you support CONSUL?")
      create(:poll_answer_video, poll: poll)

      visit admin_polls_path

      within(".poll", text: "Do you support CONSUL?") do
        accept_confirm { click_link "Delete" }
      end

      expect(page).to have_content "Poll deleted successfully"
    end

    scenario "Can't destroy poll with votes", :js do
      poll = create(:poll)
      create(:poll_question, poll: poll)
      create(:poll_voter, :from_booth, :valid_document, poll: poll)

      visit admin_polls_path

      within("#poll_#{poll.id}") do
        accept_confirm { click_link "Delete" }
      end

      expect(page).to have_content("You cannot delete a poll that has votes")
      expect(page).to have_content(poll.name)
    end
  end

  context "Booths" do
    context "Poll show" do
      scenario "No booths" do
        poll = create(:poll)
        visit admin_poll_path(poll)
        click_link "Booths (0)"

        expect(page).to have_content "There are no booths assigned to this poll."
      end

      scenario "Booth list" do
        poll = create(:poll)
        3.times { create(:poll_booth, polls: [poll]) }

        visit admin_poll_path(poll)
        click_link "Booths (3)"

        expect(page).to have_css ".booth", count: 3

        poll.booth_assignments.each do |ba|
          within("#poll_booth_assignment_#{ba.id}") do
            expect(page).to have_content ba.booth.name
            expect(page).to have_content ba.booth.location
          end
        end
        expect(page).not_to have_content "There are no booths assigned to this poll."
      end
    end
  end

  context "Officers" do
    context "Poll show" do
      scenario "No officers", :js do
        poll = create(:poll)
        visit admin_poll_path(poll)
        click_link "Officers (0)"

        expect(page).to have_content "There are no officers assigned to this poll"
      end

      scenario "Officer list", :js do
        poll = create(:poll)
        booth = create(:poll_booth, polls: [poll])

        booth.booth_assignments.each do |booth_assignment|
          3.times { create(:poll_officer_assignment, booth_assignment: booth_assignment) }
        end

        visit admin_poll_path(poll)

        click_link "Officers (3)"

        expect(page).to have_css ".officer", count: 3

        officers = Poll::Officer.all
        officers.each do |officer|
          within("#officer_#{officer.id}") do
            expect(page).to have_content officer.name
            expect(page).to have_content officer.email
          end
        end
        expect(page).not_to have_content "There are no officers assigned to this poll"
      end
    end
  end

  context "Questions" do
    context "Poll show" do
      scenario "Question list", :js do
        poll = create(:poll)
        question = create(:poll_question, poll: poll)
        other_question = create(:poll_question)

        visit admin_poll_path(poll)

        expect(page).to have_content "Questions (1)"
        expect(page).to have_content question.title
        expect(page).not_to have_content other_question.title
        expect(page).not_to have_content "There are no questions assigned to this poll"
      end
    end
  end

  context "Recounting" do
    context "Poll show" do
      scenario "No recounts", :js do
        poll = create(:poll)
        visit admin_poll_path(poll)
        click_link "Recounting"

        expect(page).to have_content "There is nothing to be recounted"
      end

      scenario "Recounts list", :js do
        poll = create(:poll)
        booth_assignment = create(:poll_booth_assignment, poll: poll)
        booth_assignment_recounted = create(:poll_booth_assignment, poll: poll)
        booth_assignment_final_recounted = create(:poll_booth_assignment, poll: poll)

        3.times do |i|
          create(:poll_recount,
                 booth_assignment: booth_assignment,
                 date: poll.starts_at + i.days,
                 total_amount: 21)
        end

        2.times do
          create(:poll_voter, :from_booth, poll: poll, booth_assignment: booth_assignment_final_recounted)
        end

        create(:poll_recount,
               booth_assignment: booth_assignment_final_recounted,
               date: poll.ends_at,
               total_amount: 55555)

        visit admin_poll_path(poll)

        click_link "Recounting"

        within("#totals") do
          within("#total_final") do
            expect(page).to have_content("#{55555 + 63}")
          end

          within("#total_system") do
            expect(page).to have_content("2")
          end
        end

        expect(page).to have_css ".booth_recounts", count: 3

        within("#poll_booth_assignment_#{booth_assignment.id}_recounts") do
          expect(page).to have_content(booth_assignment.booth.name)
          expect(page).to have_content("63")
        end

        within("#poll_booth_assignment_#{booth_assignment_recounted.id}_recounts") do
          expect(page).to have_content(booth_assignment_recounted.booth.name)
          expect(page).to have_content("-")
        end

        within("#poll_booth_assignment_#{booth_assignment_final_recounted.id}_recounts") do
          expect(page).to have_content(booth_assignment_final_recounted.booth.name)
          expect(page).to have_content("55555")
          expect(page).to have_content("2")
        end
      end

      scenario "Recounts list with old polls" do
        poll = create(:poll, :old)
        booth_assignment = create(:poll_booth_assignment, poll: poll)

        create(:poll_recount, booth_assignment: booth_assignment, total_amount: 10)
        create(:poll_voter, :from_booth, poll: poll, booth_assignment: booth_assignment)

        visit admin_poll_recounts_path(poll)

        within("#totals") do
          within("#total_final") do
            expect(page).to have_content("10")
          end

          expect(page).not_to have_selector "#total_system"
        end

        expect(page).to have_selector "#poll_booth_assignment_#{booth_assignment.id}_recounts"
        expect(page).not_to have_selector "#poll_booth_assignment_#{booth_assignment.id}_system"
      end
    end
  end

  context "Results" do
    context "Poll show" do
      scenario "No results", :js do
        poll = create(:poll)
        visit admin_poll_path(poll)
        click_link "Results"

        expect(page).to have_content "There are no results"
      end

      scenario "Show partial results" do
        poll = create(:poll)

        booth_assignment_1 = create(:poll_booth_assignment, poll: poll)
        booth_assignment_2 = create(:poll_booth_assignment, poll: poll)
        booth_assignment_3 = create(:poll_booth_assignment, poll: poll)

        question_1 = create(:poll_question, poll: poll)
        create(:poll_question_answer, title: "Oui", question: question_1)
        create(:poll_question_answer, title: "Non", question: question_1)

        question_2 = create(:poll_question, poll: poll)
        create(:poll_question_answer, title: "Aujourd'hui", question: question_2)
        create(:poll_question_answer, title: "Demain", question: question_2)

        [booth_assignment_1, booth_assignment_2, booth_assignment_3].each do |ba|
          create(:poll_partial_result,
                 booth_assignment: ba,
                 question: question_1,
                 answer: "Oui",
                 amount: 11)

          create(:poll_partial_result,
                 booth_assignment: ba,
                 question: question_2,
                 answer: "Demain",
                 amount: 5)
        end

        create(:poll_recount,
               booth_assignment: booth_assignment_1,
               white_amount: 21,
               null_amount: 44,
               total_amount: 66)

        visit admin_poll_results_path(poll)

        expect(page).to have_content "Results by booth"
      end

      scenario "Enable stats and results for booth polls" do
        unvoted_poll = create(:poll)

        voted_poll = create(:poll)
        create(:poll_voter, :from_booth, :valid_document, poll: voted_poll)

        visit admin_poll_results_path(unvoted_poll)

        expect(page).to have_content "There are no results"
        expect(page).not_to have_content "Show results and stats"

        visit admin_poll_results_path(voted_poll)

        expect(page).to have_content "Show results and stats"
        expect(page).not_to have_content "There are no results"
      end

      scenario "Enable stats and results for online polls" do
        unvoted_poll = create(:poll)

        voted_poll = create(:poll)
        create(:poll_voter, poll: voted_poll)

        visit admin_poll_results_path(unvoted_poll)

        expect(page).to have_content "There are no results"
        expect(page).not_to have_content "Show results and stats"

        visit admin_poll_results_path(voted_poll)

        expect(page).to have_content "Show results and stats"
        expect(page).not_to have_content "There are no results"
        expect(page).not_to have_content "Results by booth"
      end

      scenario "Results by answer", :js do
        poll = create(:poll)
        booth_assignment_1 = create(:poll_booth_assignment, poll: poll)
        booth_assignment_2 = create(:poll_booth_assignment, poll: poll)
        booth_assignment_3 = create(:poll_booth_assignment, poll: poll)

        question_1 = create(:poll_question, :yes_no, poll: poll)

        question_2 = create(:poll_question, poll: poll)
        create(:poll_question_answer, title: "Today", question: question_2)
        create(:poll_question_answer, title: "Tomorrow", question: question_2)

        [booth_assignment_1, booth_assignment_2, booth_assignment_3].each do |ba|
          create(:poll_partial_result,
                  booth_assignment: ba,
                  question: question_1,
                  answer: "Yes",
                  amount: 11)
          create(:poll_partial_result,
                  booth_assignment: ba,
                  question: question_2,
                  answer: "Tomorrow",
                  amount: 5)
        end
        create(:poll_recount,
               booth_assignment: booth_assignment_1,
               white_amount: 21,
               null_amount: 44,
               total_amount: 66)

        visit admin_poll_path(poll)

        click_link "Results"

        expect(page).to have_content(question_1.title)
        question_1.question_answers.each_with_index do |answer, i|
          within("#question_#{question_1.id}_#{i}_result") do
            expect(page).to have_content(answer.title)
            expect(page).to have_content([33, 0][i])
          end
        end

        expect(page).to have_content(question_2.title)
        question_2.question_answers.each_with_index do |answer, i|
          within("#question_#{question_2.id}_#{i}_result") do
            expect(page).to have_content(answer.title)
            expect(page).to have_content([0, 15][i])
          end
        end

        within("#white_results") { expect(page).to have_content("21") }
        within("#null_results") { expect(page).to have_content("44") }
        within("#total_results") { expect(page).to have_content("66") }
      end

      scenario "Link to results by booth" do
        poll = create(:poll)
        booth_assignment1 = create(:poll_booth_assignment, poll: poll)
        booth_assignment2 = create(:poll_booth_assignment, poll: poll)

        question = create(:poll_question, :yes_no, poll: poll)

        create(:poll_partial_result,
               booth_assignment: booth_assignment1,
               question: question,
               answer: "Yes",
               amount: 5)

        create(:poll_partial_result,
               booth_assignment: booth_assignment2,
               question: question,
               answer: "Yes",
               amount: 6)

        visit admin_poll_path(poll)

        click_link "Results"

        expect(page).to have_link("See results", count: 2)

        within("#booth_assignment_#{booth_assignment1.id}_result") do
          click_link "See results"
        end

        expect(page).to have_content booth_assignment1.booth.name
        expect(page).to have_content "Results"
        expect(page).to have_content "Yes"
        expect(page).to have_content "5"
      end
    end
  end

  context "SDG related list" do
    before do
      Setting["feature.sdg"] = true
      Setting["sdg.process.polls"] = true
    end

    scenario "create poll with sdg related list", :js do
      visit new_admin_poll_path
      fill_in "Name", with: "Upcoming poll with SDG related content"
      fill_in "Start Date", with: 1.week.from_now
      fill_in "Closing Date", with: 2.weeks.from_now
      fill_in "Summary", with: "Upcoming poll's summary. This poll..."
      fill_in "Description", with: "Upcomming poll's description. This poll..."

      click_sdg_goal(17)
      click_button "Create poll"
      visit admin_polls_path

      within("tr", text: "Upcoming poll with SDG related content") do
        expect(page).to have_css "td", exact_text: "17"
      end
    end

    scenario "edit poll with sdg related list", :js do
      poll = create(:poll, name: "Upcoming poll with SDG related content")
      poll.sdg_goals = [SDG::Goal[1], SDG::Goal[17]]
      visit edit_admin_poll_path(poll)

      remove_sdg_goal_or_target_tag(1)
      click_button "Update poll"
      visit admin_polls_path

      within("tr", text: "Upcoming poll with SDG related content") do
        expect(page).to have_css "td", exact_text: "17"
      end
    end
  end
end
