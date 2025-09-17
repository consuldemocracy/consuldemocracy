require "rails_helper"

describe "Officing Results", :with_frozen_time do
  let(:poll) { create(:poll, ends_at: 1.day.ago) }
  let(:booth) { create(:poll_booth, polls: [poll]) }
  let(:poll_officer) { create(:poll_officer) }
  let(:question_1) { create(:poll_question, poll: poll) }
  let(:question_2) { create(:poll_question, poll: poll) }

  before do
    create(:poll_shift, :recount_scrutiny_task, officer: poll_officer, booth: booth, date: Date.current)
    create(:poll_question_option, title: "Yes", question: question_1, given_order: 1)
    create(:poll_question_option, title: "No", question: question_1, given_order: 2)

    create(:poll_question_option, title: "Today", question: question_2, given_order: 1)
    create(:poll_question_option, title: "Tomorrow", question: question_2, given_order: 2)

    login_as(poll_officer.user)
    set_officing_booth(booth)
  end

  scenario "Only polls where user is officer for results are accessible" do
    not_allowed_poll_1 = create(:poll, :expired)
    not_allowed_poll_2 = create(:poll, officers: [poll_officer], ends_at: 1.day.ago)
    not_allowed_poll_3 = create(:poll, officers: [poll_officer])

    visit root_path
    click_link "Menu"
    click_link "Polling officers"

    expect(page).to have_content("Poll officing")

    within("#side_menu") do
      click_link "Total recounts and results"
    end

    expect(page).not_to have_content(not_allowed_poll_1.name)
    expect(page).not_to have_content(not_allowed_poll_2.name)
    expect(page).not_to have_content(not_allowed_poll_3.name)
    expect(page).to have_content(poll.name)

    visit new_officing_poll_result_path(not_allowed_poll_1)
    expect(page).to have_content("You are not allowed to add results for this poll")
  end

  scenario "Add results" do
    visit officing_root_path

    within("#side_menu") do
      click_link "Total recounts and results"
    end

    within("#poll_#{poll.id}") do
      expect(page).to have_content(poll.name)
      click_link "Add results"
    end

    expect(page).not_to have_content("Your results")

    select booth.name, from: "Booth"

    within_fieldset question_1.title do
      fill_in "Yes", with: "100"
      fill_in "No", with: "200"
    end

    within_fieldset question_2.title do
      fill_in "Today", with: "333"
      fill_in "Tomorrow", with: "444"
    end

    fill_in "Totally blank ballots", with: "66"
    fill_in "Invalid ballots", with: "77"
    fill_in "Valid ballots", with: "88"

    click_button "Save"

    expect(page).to have_content("Your results")

    within "tbody tr" do
      expect(page).to have_content(I18n.l(Date.current, format: :long))
      expect(page).to have_content(booth.name)
    end
  end

  scenario "Edit result" do
    partial_result = create(:poll_partial_result,
                            officer_assignment: poll_officer.officer_assignments.first,
                            booth_assignment: poll_officer.officer_assignments.first.booth_assignment,
                            date: Date.current,
                            question: question_1,
                            answer: question_1.question_options.first.title,
                            author: poll_officer.user,
                            amount: 7777)

    visit officing_poll_results_path(poll,
                                     date: I18n.l(partial_result.date),
                                     booth_assignment_id: partial_result.booth_assignment_id)

    within("#question_#{question_1.id}_0_result") { expect(page).to have_content("7777") }

    visit new_officing_poll_result_path(poll)

    booth_name = partial_result.booth_assignment.booth.name
    select booth_name, from: "Booth"

    within_fieldset question_1.title do
      fill_in "Yes", with: "5555"
      fill_in "No", with: "200"
    end

    fill_in "Totally blank ballots", with: "6"
    fill_in "Invalid ballots", with: "7"
    fill_in "Valid ballots", with: "8"

    click_button "Save"

    within("#results_#{partial_result.booth_assignment_id}_#{partial_result.date.strftime("%Y%m%d")}") do
      expect(page).to have_content(I18n.l(partial_result.date, format: :long))
      expect(page).to have_content(partial_result.booth_assignment.booth.name)
      click_link "See results"
    end

    within("#question_#{question_1.id}_0_result") do
      expect(page).to have_content("5555")
      expect(page).not_to have_content("7777")
    end

    within("#white_results") { expect(page).to have_content("6") }
    within("#null_results")  { expect(page).to have_content("7") }
    within("#total_results") { expect(page).to have_content("8") }
    within("#question_#{question_1.id}_0_result") { expect(page).to have_content("5555") }
    within("#question_#{question_1.id}_1_result") { expect(page).to have_content("200") }
  end

  scenario "Index lists all questions and answers" do
    officer_assignment = poll_officer.officer_assignments.first
    booth_assignment = officer_assignment.booth_assignment
    booth = booth_assignment.booth

    create(:poll_partial_result,
           officer_assignment: officer_assignment,
           booth_assignment: booth_assignment,
           date: poll.ends_at,
           question: question_1,
           amount: 33)

    create(:poll_recount,
           officer_assignment: officer_assignment,
           booth_assignment: booth_assignment,
           date: poll.ends_at,
           white_amount: 21,
           null_amount: 44,
           total_amount: 66)

    visit officing_poll_results_path(poll,
                                     date: I18n.l(poll.ends_at.to_date),
                                     booth_assignment_id: officer_assignment.booth_assignment_id)

    expect(page).to have_content(I18n.l(poll.ends_at.to_date, format: :long))
    expect(page).to have_content(booth.name)

    expect(page).to have_content(question_1.title)
    question_1.question_options.each_with_index do |answer, i|
      within("#question_#{question_1.id}_#{i}_result") { expect(page).to have_content(answer.title) }
    end

    expect(page).to have_content(question_2.title)
    question_2.question_options.each_with_index do |answer, i|
      within("#question_#{question_2.id}_#{i}_result") { expect(page).to have_content(answer.title) }
    end

    within("#white_results") { expect(page).to have_content("21") }
    within("#null_results") { expect(page).to have_content("44") }
    within("#total_results") { expect(page).to have_content("66") }
  end
end
