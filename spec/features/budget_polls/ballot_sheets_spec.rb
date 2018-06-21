require 'rails_helper'

feature 'Poll budget ballot sheets' do
  let(:budget) { create(:budget) }
  let(:poll) { create(:poll, budget: budget, ends_at: 1.day.ago) }
  let(:booth) { create(:poll_booth) }
  let(:poll_officer) { create(:poll_officer) }

  background do
    create(:poll_booth_assignment, poll: poll, booth: booth)
    create(:poll_shift, :recount_scrutiny_task, officer: poll_officer, booth: booth, date: Date.current)
    create(:poll_officer_assignment, officer: poll_officer)

    login_as(poll_officer.user)
    set_officing_booth(booth)
  end

  scenario "Budget polls are visible in 'Recounts and results' view" do
    visit root_path
    click_link 'Polling officers'

    within('#side_menu') do
      click_link 'Total recounts and results'
    end

    within("#poll_#{poll.id}") do
      expect(page).to have_content("#{poll.name}")
      expect(page).to have_content("See ballot sheets list")
      expect(page).to have_content("Add results")
    end
  end
end
