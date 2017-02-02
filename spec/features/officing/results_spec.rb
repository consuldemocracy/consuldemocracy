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
    click_button 'Save'

    expect(page).to have_content('Your results')

    within("#results_#{@officer_assignment.booth_assignment_id}_#{@poll.starts_at.to_date.strftime('%Y%m%d')}") do
      expect(page).to have_content(date)
      expect(page).to have_content(booth_name)
    end
  end

end