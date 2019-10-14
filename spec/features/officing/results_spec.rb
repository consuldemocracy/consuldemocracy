require 'rails_helper'

feature 'Officing Results' do

  background do
    @poll_officer = create(:poll_officer)
    @officer_assignment = create(:poll_officer_assignment, :final, officer: @poll_officer)
    @poll = @officer_assignment.booth_assignment.poll
    @poll.update(ends_at: 1.day.ago)
    @question_1 = create(:poll_question, poll: @poll, valid_answers: "Yes,No")
    @question_2 = create(:poll_question, poll: @poll, valid_answers: "Today,Tomorrow")
    login_as(@poll_officer.user)
  end

  scenario 'Only polls where user is officer for results are accessible' do
    regular_officer_assignment_1 = create(:poll_officer_assignment, officer: @poll_officer)
    regular_officer_assignment_2 = create(:poll_officer_assignment, officer: @poll_officer)

    not_allowed_poll_1 = create(:poll, :expired)
    not_allowed_poll_2 = regular_officer_assignment_1.booth_assignment.poll
    not_allowed_poll_2.update(ends_at: 1.day.ago)
    not_allowed_poll_3 = regular_officer_assignment_2.booth_assignment.poll

    visit root_path
    click_link 'Polling officers'

    expect(page).to have_content('Poll officing')
    within('#side_menu') do
      click_link 'Final recounts and results'
    end

    expect(page).to_not have_content(not_allowed_poll_1.name)
    expect(page).to_not have_content(not_allowed_poll_2.name)
    expect(page).to_not have_content(not_allowed_poll_3.name)
    expect(page).to have_content(@poll.name)

    visit new_officing_poll_result_path(not_allowed_poll_1)
    expect(page).to have_content('You are allowed to add results for this poll')
  end

  scenario 'Add results' do
    visit officing_root_path

    within('#side_menu') do
      click_link 'Final recounts and results'
    end

    within("#poll_#{@poll.id}") do
      expect(page).to have_content(@poll.name)
      click_link 'Add results'
    end

    expect(page).to_not have_content('Your results')

    booth_name = @officer_assignment.booth_assignment.booth.name
    date = I18n.l(@poll.starts_at.to_date, format: :long)
    select booth_name, from: 'officer_assignment_id'
    select date, from: 'date'

    fill_in "questions[#{@question_1.id}][0]", with: '100'
    fill_in "questions[#{@question_1.id}][1]", with: '200'

    fill_in "questions[#{@question_2.id}][0]", with: '333'
    fill_in "questions[#{@question_2.id}][1]", with: '444'

    fill_in "whites", with: '66'
    fill_in "nulls",  with: '77'

    click_button 'Save'

    expect(page).to have_content('Your results')

    within("#results_#{@officer_assignment.booth_assignment_id}_#{@poll.starts_at.to_date.strftime('%Y%m%d')}") do
      expect(page).to have_content(date)
      expect(page).to have_content(booth_name)
    end
  end

  scenario 'Edit result' do
    partial_result = create(:poll_partial_result,
                      officer_assignment: @officer_assignment,
                      booth_assignment: @officer_assignment.booth_assignment,
                      date: @poll.starts_at,
                      question: @question_1,
                      answer: @question_1.valid_answers[0],
                      author: @poll_officer.user,
                      amount: 7777)

    visit officing_poll_results_path(@poll, date: I18n.l(partial_result.date), booth_assignment_id: partial_result.booth_assignment_id)

    within("#question_#{@question_1.id}_0_result") { expect(page).to have_content('7777') }

    visit new_officing_poll_result_path(@poll)

    booth_name = partial_result.booth_assignment.booth.name
    date = I18n.l(partial_result.date, format: :long)
    select booth_name, from: 'officer_assignment_id'
    select date, from: 'date'

    fill_in "questions[#{@question_1.id}][0]", with: '5555'
    fill_in "questions[#{@question_1.id}][1]", with: '200'
    fill_in "whites", with: '6'
    fill_in "nulls",  with: '7'

    click_button 'Save'

    within("#results_#{partial_result.booth_assignment_id}_#{partial_result.date.strftime('%Y%m%d')}") do
      expect(page).to have_content(I18n.l(partial_result.date, format: :long))
      expect(page).to have_content(partial_result.booth_assignment.booth.name)
      click_link "See results"
    end

    expect(page).to_not have_content('7777')
    within("#white_results") { expect(page).to have_content('6') }
    within("#null_results")  { expect(page).to have_content('7') }
    within("#question_#{@question_1.id}_0_result") { expect(page).to have_content('5555') }
    within("#question_#{@question_1.id}_1_result") { expect(page).to have_content('200') }
  end

  scenario 'Index lists all questions and answers' do
    partial_result = create(:poll_partial_result,
                      officer_assignment: @officer_assignment,
                      booth_assignment: @officer_assignment.booth_assignment,
                      date: @poll.ends_at,
                      question: @question_1,
                      amount: 33)
    white_result = create(:poll_white_result,
                      officer_assignment: @officer_assignment,
                      booth_assignment: @officer_assignment.booth_assignment,
                      date: @poll.ends_at,
                      amount: 21)
    null_result = create(:poll_null_result,
                      officer_assignment: @officer_assignment,
                      booth_assignment: @officer_assignment.booth_assignment,
                      date: @poll.ends_at,
                      amount: 44)

    visit officing_poll_results_path(@poll,
                                     date: I18n.l(@poll.ends_at.to_date),
                                     booth_assignment_id: @officer_assignment.booth_assignment_id)

    expect(page).to have_content(I18n.l(@poll.ends_at.to_date, format: :long))
    expect(page).to have_content(@officer_assignment.booth_assignment.booth.name)

    expect(page).to have_content(@question_1.title)
    @question_1.valid_answers.each_with_index do |answer, i|
      within("#question_#{@question_1.id}_#{i}_result") { expect(page).to have_content(answer) }
    end

    expect(page).to have_content(@question_2.title)
    @question_2.valid_answers.each_with_index do |answer, i|
      within("#question_#{@question_2.id}_#{i}_result") { expect(page).to have_content(answer) }
    end

    within('#white_results') { expect(page).to have_content('21') }
    within('#null_results') { expect(page).to have_content('44') }
  end

end