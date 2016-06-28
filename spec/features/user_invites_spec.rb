require 'rails_helper'

feature 'User invites' do

  scenario "Send invitations" do
    login_as_manager

    visit new_management_user_invite_path

    fill_in "emails", with: "john@example.com, ana@example.com, isable@example.com"
    click_button "Send invites"

    expect(page).to have_content "3 invitations have been sent."
  end

  context "Tracking" do

    background do
      create(:campaign, track_id: 172943750183759812)
    end

    scenario "Clicks on registration button" do
      login_as_manager
      send_user_invite
      logout(:user)

      email = open_last_email
      visit_in_email "Complete registration"

      expect(current_url).to include(new_user_registration_path)
      click_button "Register"

      admin = create(:administrator)
      login_as(admin.user)

      visit admin_stats_path
      click_link "Invitations"

      within("#clicked_email_link") do
        expect(page).to have_content "1"
      end

      within("#clicked_signup_button") do
        expect(page).to have_content "1"
      end
    end

    scenario "Does not click on registration button" do
      login_as_manager
      send_user_invite
      logout(:user)

      email = open_last_email
      visit_in_email "Complete registration"

      expect(current_url).to include(new_user_registration_path)

      admin = create(:administrator)
      login_as(admin.user)

      visit admin_stats_path
      click_link "Invitations"

      within("#clicked_email_link") do
        expect(page).to have_content "1"
      end

      within("#clicked_signup_button") do
        expect(page).to have_content "0"
      end
    end

  end

end