require 'rails_helper'

feature 'Officing Final Recount' do

  background do
    @poll_officer = create(:poll_officer)
    @officer_assignment = create(:poll_officer_assignment, :final, officer: @poll_officer)
    @poll = @officer_assignment.booth_assignment.poll
    @poll.update(ends_at: 1.day.ago)
    login_as(@poll_officer.user)
  end

  scenario 'Only polls where user is officer for final recounts are accessible' do
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

    visit new_officing_poll_final_recount_path(not_allowed_poll_1)
    expect(page).to have_content('You are allowed to add final recounts for this poll')
  end

  scenario 'Add final recount' do
    visit officing_root_path

    within('#side_menu') do
      click_link 'Final recounts and results'
    end

    within("#poll_#{@poll.id}") do
      expect(page).to have_content(@poll.name)
      click_link 'Add final recount'
    end

    expect(page).to_not have_content('Your recounts')

    booth_name = @officer_assignment.booth_assignment.booth.name
    date = I18n.l(@poll.starts_at.to_date, format: :long)
    select booth_name, from: 'officer_assignment_id'
    select date, from: 'date'
    fill_in :count, with: '33'
    click_button 'Save'

    expect(page).to have_content('Your final recounts')

    within("#poll_final_recount_#{@officer_assignment.booth_assignment.final_recounts.first.id}") do
      expect(page).to have_content(date)
      expect(page).to have_content(booth_name)
      expect(page).to have_content('33')
    end
  end

  scenario 'Edit final recount' do
    final_recount = create(:poll_final_recount,
                    officer_assignment: @officer_assignment,
                    booth_assignment: @officer_assignment.booth_assignment,
                    date: @poll.starts_at,
                    count: 100)

    booth_name = @officer_assignment.booth_assignment.booth.name
    date = I18n.l(final_recount.date.to_date, format: :long)

    visit new_officing_poll_final_recount_path(@poll)

    expect(page).to have_content('Your final recounts')

    within("#poll_final_recount_#{final_recount.id}") do
      expect(page).to have_content(date)
      expect(page).to have_content(booth_name)
      expect(page).to have_content('100')
    end

    select booth_name, from: 'officer_assignment_id'
    select date, from: 'date'
    fill_in :count, with: '42'
    click_button 'Save'

    expect(page).to have_content "Data added"

    within("#poll_final_recount_#{final_recount.id}") do
      expect(page).to have_content(date)
      expect(page).to have_content(booth_name)
      expect(page).to have_content('42')
    end
    expect(page).to_not have_content('100')
  end

  scenario 'Show final and system recounts to compare' do
    final_officer_assignment = create(:poll_officer_assignment, :final, officer: @poll_officer)
    poll = final_officer_assignment.booth_assignment.poll
    poll.update(ends_at: 1.day.ago)
    final_recount = create(:poll_final_recount,
                    officer_assignment: final_officer_assignment,
                    booth_assignment: final_officer_assignment.booth_assignment,
                    date: 7.days.ago,
                    count: 100)
    33.times do
      create(:poll_voter, :valid_document,
             poll: poll,
             booth_assignment: final_officer_assignment.booth_assignment,
             created_at: final_recount.date)
    end

    visit new_officing_poll_final_recount_path(poll)
    within("#poll_final_recount_#{final_recount.id}") do
      expect(page).to have_content(I18n.l(final_recount.date.to_date, format: :long))
      expect(page).to have_content(final_officer_assignment.booth_assignment.booth.name)
      expect(page).to have_content('100')
      expect(page).to have_content('33')
    end
  end

  scenario "Show link to add results for same booth/date" do
    final_officer_assignment = create(:poll_officer_assignment, :final, officer: @poll_officer)
    poll = final_officer_assignment.booth_assignment.poll
    poll.update(ends_at: 1.day.ago)
    final_recount = create(:poll_final_recount,
                    officer_assignment: final_officer_assignment,
                    booth_assignment: final_officer_assignment.booth_assignment,
                    date: 7.days.ago,
                    count: 100)
    visit new_officing_poll_final_recount_path(poll)
    within("#poll_final_recount_#{final_recount.id}") do
      click_link "Add results"
    end

    expected_path = new_officing_poll_result_path(poll, oa: final_recount.officer_assignment.id, d: I18n.l(final_recount.date.to_date))
    expect(page).to have_current_path(expected_path)
    expect(page).to have_select('officer_assignment_id', selected: final_recount.booth_assignment.booth.name)
    expect(page).to have_select('date', selected: I18n.l(final_recount.date.to_date, format: :long))
  end

end
