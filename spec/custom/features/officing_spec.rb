require 'rails_helper'
require 'sessions_helper'

feature 'Poll Officing' do
  let(:user) { create(:user) }

  scenario 'Officing dashboard available for multiple sessions', :js do
    poll = create(:poll)
    booth = create(:poll_booth)
    booth_assignment = create(:poll_booth_assignment, poll: poll, booth: booth)

    user1 = create(:user)
    user2 = create(:user)
    officer1 = create(:poll_officer, user: user1)
    officer2 = create(:poll_officer, user: user2)

    create(:poll_shift, officer: officer1, booth: booth, date: Date.current, task: :vote_collection)
    create(:poll_shift, officer: officer2, booth: booth, date: Date.current, task: :vote_collection)

    officer_assignment_1 = create(:poll_officer_assignment, booth_assignment: booth_assignment, officer: officer1)
    officer_assignment_2 = create(:poll_officer_assignment, booth_assignment: booth_assignment, officer: officer2)

    in_browser(:one) do
      login_as user1
      visit officing_root_path
    end

    in_browser(:two) do
      login_as user2
      visit officing_root_path
    end

    in_browser(:one) do
      expect(page).to have_content("Here you can validate user documents and store voting results")

      visit new_officing_residence_path
      select 'DNI', from: 'residence_document_type'
      fill_in 'residence_document_number', with: "12345678Z"
      fill_in 'residence_year_of_birth', with: "#{valid_date_of_birth_year}"
      click_button 'Validate document'
      expect(page).to have_content 'Document verified with Census'
      click_button "Confirm vote"
      expect(page).to have_content "Vote introduced!"
      expect(Poll::Voter.where(document_number: '12345678Z', poll_id: poll, origin: 'booth', officer_id: officer1).count).to be(1)

      visit final_officing_polls_path
      expect(page).to have_content("Polls ready for final recounting")
    end

    in_browser(:two) do
      expect(page).to have_content("Here you can validate user documents and store voting results")

      visit new_officing_residence_path
      select 'DNI', from: 'residence_document_type'
      fill_in 'residence_document_number', with: "12345678Y"
      fill_in 'residence_year_of_birth', with: "#{valid_date_of_birth_year}"
      click_button 'Validate document'
      expect(page).to have_content 'Document verified with Census'
      click_button "Confirm vote"
      expect(page).to have_content "Vote introduced!"
      expect(Poll::Voter.where(document_number: '12345678Y', poll_id: poll, origin: 'booth', officer_id: officer2).count).to be(1)

      visit final_officing_polls_path
      expect(page).to have_content("Polls ready for final recounting")
    end
  end
end
