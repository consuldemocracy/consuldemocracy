require 'rails_helper'

feature 'Officing Recount' do

  background do
    @poll_officer = create(:poll_officer)
    @officer_assignment = create(:poll_officer_assignment, officer: @poll_officer)
    @poll = @officer_assignment.booth_assignment.poll
    login_as(@poll_officer.user)
  end

  scenario 'Only polls where user is officer are accessible' do
    not_allowed_poll = create(:poll)

    visit root_path
    click_link 'Polling officers'

    expect(page).to have_content('Poll officing')
    within('#side_menu') do
      click_link 'Store recount'
    end

    expect(page).to_not have_content(not_allowed_poll.name)
    expect(page).to have_content(@poll.name)

    visit new_officing_poll_recount_path(not_allowed_poll)
    expect(page).to have_content('You are not a poll officer for this poll')
  end

  scenario 'Add recount' do
    visit officing_root_path

    within('#side_menu') do
      click_link 'Store recount'
    end

    click_link @poll.name

    expect(page).to_not have_content('Your recounts')

    booth_name = @officer_assignment.booth_assignment.booth.name
    date = I18n.l(@officer_assignment.date.to_date, format: :long)
    select "#{booth_name}: #{date}", from: 'officer_assignment_id'
    fill_in :count, with: '33'
    click_button 'Save'

    expect(page).to have_content('Your recounts')

    within("#poll_recount_#{@officer_assignment.booth_assignment.recounts.first.id}") do
      expect(page).to have_content(date)
      expect(page).to have_content(booth_name)
      expect(page).to have_content('33')
    end
  end

  scenario 'Edit recount' do
    recount = create(:poll_recount,
                    officer_assignment: @officer_assignment,
                    booth_assignment: @officer_assignment.booth_assignment,
                    date: @officer_assignment.date,
                    count: 100)

    booth_name = @officer_assignment.booth_assignment.booth.name
    date = I18n.l(@officer_assignment.date.to_date, format: :long)

    visit new_officing_poll_recount_path(@poll)

    expect(page).to have_content('Your recounts')

    within("#poll_recount_#{recount.id}") do
      expect(page).to have_content(date)
      expect(page).to have_content(booth_name)
      expect(page).to have_content('100')
    end

    select "#{booth_name}: #{date}", from: 'officer_assignment_id'
    fill_in :count, with: '42'
    click_button 'Save'

    within("#poll_recount_#{recount.id}") do
      expect(page).to have_content(date)
      expect(page).to have_content(booth_name)
      expect(page).to have_content('42')
    end
    expect(page).to_not have_content('100')
  end
end