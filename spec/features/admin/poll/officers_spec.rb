require 'rails_helper'

feature 'Admin poll officers' do

  background do
    @admin = create(:administrator)
    @user  = create(:user, username: 'Pedro Jose Garcia')
    @officer = create(:poll_officer)
    login_as(@admin.user)
    visit admin_officers_path
  end

  scenario 'Index' do
    expect(page).to have_content @officer.name
    expect(page).to have_content @officer.email
    expect(page).to_not have_content @user.name
  end

  scenario 'Create', :js do
    fill_in 'email', with: @user.email
    click_button 'Search'

    expect(page).to have_content @user.name
    click_link 'Add'
    within("#officers") do
      expect(page).to have_content @user.name
    end
  end

  scenario 'Delete' do
    click_link 'Delete'

    within("#officers") do
      expect(page).to_not have_content @officer.name
    end
  end

  context "Booth" do

    scenario 'No officers assigned to booth' do
      poll = create(:poll)
      booth = create(:poll_booth, poll: poll)

      visit admin_poll_booth_path(poll, booth)

      within("#assigned_officers") do
        expect(page).to have_css ".officer", count: 0
      end

      expect(page).to have_content "There are no officers assigned to this booth"
    end

    scenario "Assigned to booth" do
      john   = create(:poll_officer)
      isabel = create(:poll_officer)
      eve    = create(:poll_officer)

      poll = create(:poll)
      booth = create(:poll_booth, poll: poll)

      officing_booth1 = create(:officing_booth, officer: john,   booth: booth)
      officing_booth2 = create(:officing_booth, officer: isabel, booth: booth)

      visit admin_poll_booth_path(poll, booth)

      within("#assigned_officers") do
        expect(page).to have_css ".officer", count: 2
        expect(page).to have_content john.name
        expect(page).to have_content isabel.name

        expect(page).to_not have_content eve.name
      end

      expect(page).to_not have_content "There are no officers assigned to this booth"
    end

    scenario 'Assign to booth' do
      john = create(:poll_officer)
      isabel = create(:poll_officer)

      poll = create(:poll)
      booth = create(:poll_booth, poll: poll)

      visit admin_poll_booth_path(poll, booth)

      check "#{john.name} - #{john.email}"
      click_button "Assign officer"

      expect(page).to have_content "Booth updated successfully."
      within("#assigned_officers") do
        expect(page).to have_css ".officer", count: 1
        expect(page).to have_content john.name
      end
    end

    scenario "Unassign from booth" do
      john = create(:poll_officer)
      isabel = create(:poll_officer)

      poll = create(:poll)
      booth = create(:poll_booth, poll: poll)

      officing_booth = create(:officing_booth, officer: john, booth: booth)
      officing_booth = create(:officing_booth, officer: isabel, booth: booth)

      visit admin_poll_booth_path(poll, booth)

      uncheck "#{john.name} - #{john.email}"
      click_button "Assign officer"

      expect(page).to have_content "Booth updated successfully."
      within("#assigned_officers") do
        expect(page).to have_css ".officer", count: 1
        expect(page).to have_content isabel.name

        expect(page).to_not have_content john.name
      end
    end

    scenario "Assigned multiple officers to different booths" do
      john = create(:poll_officer)
      isabel = create(:poll_officer)
      eve    = create(:poll_officer)
      peter  = create(:poll_officer)

      poll1 = create(:poll)
      poll2 = create(:poll)

      booth1 = create(:poll_booth, poll: poll1)
      booth2 = create(:poll_booth, poll: poll1)
      booth3 = create(:poll_booth, poll: poll2)

      officing_booth = create(:officing_booth, officer: john,   booth: booth1)
      officing_booth = create(:officing_booth, officer: isabel, booth: booth1)
      officing_booth = create(:officing_booth, officer: eve,    booth: booth2)
      officing_booth = create(:officing_booth, officer: peter,  booth: booth3)

      visit admin_poll_booth_path(poll1, booth1)
      within("#assigned_officers") do
        expect(page).to have_css ".officer", count: 2
        expect(page).to have_content john.name
        expect(page).to have_content isabel.name
      end

      visit admin_poll_booth_path(poll1, booth2)
      within("#assigned_officers") do
        expect(page).to have_css ".officer", count: 1
        expect(page).to have_content eve.name
      end

      visit admin_poll_booth_path(poll2, booth3)
      within("#assigned_officers") do
        expect(page).to have_css ".officer", count: 1
        expect(page).to have_content peter.name
      end
    end
  end

end