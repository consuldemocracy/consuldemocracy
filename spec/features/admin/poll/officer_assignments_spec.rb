require 'rails_helper'

feature 'Admin officer assignments in poll' do

  background do
    admin = create(:administrator)
    login_as(admin.user)
  end

  scenario 'Assign officer to poll', :js do
    booth_assignment = create(:poll_booth_assignment)
    officer = create(:poll_officer)

    visit admin_poll_path(booth_assignment.poll)
    within('#poll-resources') do
      click_link 'Officers (0)'
    end

    expect(page).to have_content 'There are no officers assigned to this poll'

    fill_in 'search-officers', with: officer.name
    click_button 'Search'

    within('#search-officers-results') do
      click_link 'Add shifts as officer'
    end

    expect(page).to have_content 'This user has no officing shifts in this poll'
    expect(page).to have_content officer.name
    expect(page).to have_content booth_assignment.poll.name

    within('#officer_assignment_form') do
      select I18n.l(booth_assignment.poll.ends_at.to_date, format: :long), from: 'date'
      select "#{booth_assignment.booth.name} (#{booth_assignment.booth.location})", from: 'booth_id'
      click_button 'Add shift'
    end

    expect(page).to have_content 'Officing shift added'
    expect(page).to_not have_content 'This user has no officing shifts in this poll'

    visit admin_poll_path(booth_assignment.poll)
    within('#poll-resources') do
      click_link 'Officers (1)'
    end

    expect(page).to_not have_content 'There are no officers in this poll'
    expect(page).to have_content officer.name
    expect(page).to have_content officer.email
  end

  scenario 'Remove officer assignment from poll' do
    officer_assignment = create(:poll_officer_assignment)
    poll = officer_assignment.booth_assignment.poll
    booth = officer_assignment.booth_assignment.booth
    officer = officer_assignment.officer

    visit by_officer_admin_poll_officer_assignments_path(poll, officer_id: officer.id)

    expect(page).to_not have_content 'This user has no officing shifts in this poll'
    within("#poll_officer_assignment_#{officer_assignment.id}") do
      expect(page).to have_content booth.name
      click_link 'Remove'
    end

    expect(page).to have_content 'Officing shift removed'
    expect(page).to have_content 'This user has no officing shifts in this poll'
  end

  scenario 'Index view shows recounts info for officer' do
    booth_assignment = create(:poll_booth_assignment)
    poll = booth_assignment.poll
    officer = create(:poll_officer)
    create(:poll_officer_assignment,
            booth_assignment: booth_assignment,
            officer: officer,
            date: poll.starts_at)
    final_officer_assignment = create(:poll_officer_assignment, :final,
                                       booth_assignment: booth_assignment,
                                       officer: officer,
                                       date: poll.ends_at + 1.day)
    create(:poll_final_recount,
           booth_assignment: booth_assignment,
           officer_assignment: final_officer_assignment,
           date: poll.ends_at,
           count: 9876)

    visit by_officer_admin_poll_officer_assignments_path(poll, officer_id: officer.id)

    within('#final_recount_list') { expect(page).to have_content('9876') }
  end
end
