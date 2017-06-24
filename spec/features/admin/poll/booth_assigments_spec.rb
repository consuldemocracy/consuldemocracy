require 'rails_helper'

feature 'Admin booths assignments' do

  background do
    admin = create(:administrator)
    login_as(admin.user)
  end

  scenario 'Assign booth to poll', :js do
    poll = create(:poll)
    booth = create(:poll_booth)

    visit admin_poll_path(poll)
    within('#poll-resources') do
      click_link 'Booths (0)'
    end

    expect(page).to have_content 'There are no booths assigned to this poll.'

    fill_in 'search-booths', with: booth.name
    click_button 'Search'
    expect(page).to have_content(booth.name)

    within('#search-booths-results') do
      click_link 'Assign booth'
    end

    expect(page).to have_content 'Booth assigned'

    visit admin_poll_path(poll)
    within('#poll-resources') do
      click_link 'Booths (1)'
    end

    expect(page).to_not have_content 'There are no booths assigned to this poll.'
    expect(page).to have_content booth.name
  end

  scenario 'Remove booth from poll', :js do
    poll = create(:poll)
    booth = create(:poll_booth)
    assignment = create(:poll_booth_assignment, poll: poll, booth: booth)

    visit admin_poll_path(poll)
    within('#poll-resources') do
      click_link 'Booths (1)'
    end

    expect(page).to_not have_content 'There are no booths assigned to this poll.'
    expect(page).to have_content booth.name

    within("#poll_booth_assignment_#{assignment.id}") do
      click_link 'Remove booth from poll'
    end

    expect(page).to have_content 'Booth not assigned anymore'

    visit admin_poll_path(poll)
    within('#poll-resources') do
      click_link 'Booths (0)'
    end

    expect(page).to have_content 'There are no booths assigned to this poll.'
    expect(page).to_not have_content booth.name
  end

  feature 'Show' do
    scenario 'Lists all assigned poll oficers' do
      poll = create(:poll)
      booth = create(:poll_booth)
      booth_assignment = create(:poll_booth_assignment, poll: poll, booth: booth)
      officer_assignment = create(:poll_officer_assignment, booth_assignment: booth_assignment)
      officer = officer_assignment.officer

      booth_assignment_2 = create(:poll_booth_assignment, poll: poll)
      officer_assignment_2 = create(:poll_officer_assignment, booth_assignment: booth_assignment_2)
      officer_2 = officer_assignment_2.officer

      visit admin_poll_path(poll)
      click_link 'Booths (2)'

      within('#assigned_booths_list') { click_link booth.name }

      click_link 'Officers'
      within('#officers_list') do
        expect(page).to have_content officer.name
        expect(page).to_not have_content officer_2.name
      end
    end

    scenario 'Lists all recounts for the booth assignment' do
      poll = create(:poll, starts_at: 2.weeks.ago, ends_at: 1.week.ago)
      booth = create(:poll_booth)
      booth_assignment = create(:poll_booth_assignment, poll: poll, booth: booth)
      officer_assignment_1 = create(:poll_officer_assignment, booth_assignment: booth_assignment, date: poll.starts_at)
      officer_assignment_2 = create(:poll_officer_assignment, booth_assignment: booth_assignment, date: poll.ends_at)
      final_officer_assignment = create(:poll_officer_assignment, :final, booth_assignment: booth_assignment, date: poll.ends_at)

      recount_1 = create(:poll_recount,
                         booth_assignment: booth_assignment,
                         officer_assignment: officer_assignment_1,
                         date: officer_assignment_1.date,
                         count: 33)
      recount_2 = create(:poll_recount,
                         booth_assignment: booth_assignment,
                         officer_assignment: officer_assignment_2,
                         date: officer_assignment_2.date,
                         count: 78)
      final_recount = create(:poll_final_recount,
                         booth_assignment: booth_assignment,
                         officer_assignment: final_officer_assignment,
                         date: final_officer_assignment.date,
                         count: 5678)

      booth_assignment_2 = create(:poll_booth_assignment, poll: poll)
      other_recount = create(:poll_recount, booth_assignment: booth_assignment_2, count: 100)

      visit admin_poll_path(poll)
      click_link 'Booths (2)'

      within('#assigned_booths_list') { click_link booth.name }

      click_link 'Recounts'
      within('#recounts_list') do
        expect(page).to_not have_content other_recount.count

        within("#recounting_#{recount_1.date.strftime('%Y%m%d')}") do
          expect(page).to have_content recount_1.count
        end

        within("#recounting_#{recount_2.date.strftime('%Y%m%d')}") do
          expect(page).to have_content recount_2.count
        end

        within("#recounting_#{final_recount.date.strftime('%Y%m%d')}") do
          expect(page).to have_content final_recount.count
        end

      end
    end

    scenario 'Marks recount values with count-errors' do
      poll = create(:poll)
      booth = create(:poll_booth)
      booth_assignment = create(:poll_booth_assignment, poll: poll, booth: booth)
      today = Date.current
      officer_assignment = create(:poll_officer_assignment, booth_assignment: booth_assignment, date: today)

      recount = create(:poll_recount,
                         booth_assignment: booth_assignment,
                         officer_assignment: officer_assignment,
                         date: officer_assignment.date,
                         count: 1)

      visit admin_poll_booth_assignment_path(poll, booth_assignment)
      click_link 'Recounts'

      within('#recounts_list') do
        expect(page).to have_css("#recounting_#{recount.date.strftime('%Y%m%d')} td.count-error")
        within("#recounting_#{recount.date.strftime('%Y%m%d')}") do
          expect(page).to have_content recount.count
          expect(page).to have_content 0
        end
      end

      create(:poll_voter, :valid_document, poll: poll, booth_assignment: booth_assignment)

      visit admin_poll_booth_assignment_path(poll, booth_assignment)
      click_link 'Recounts'

      within('#recounts_list') do
        expect(page).to_not have_css('.count-error')
        within("#recounting_#{recount.date.strftime('%Y%m%d')}") do
          expect(page).to have_content(recount.count)
        end
      end
    end

  end
end
