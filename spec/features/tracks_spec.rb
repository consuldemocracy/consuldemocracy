require "rails_helper"

feature "Tracking" do

  context "Custom variable" do

     scenario "Usertype anonymous" do
      visit proposals_path

      expect(page.html).to include "anonymous"
     end

    scenario "Usertype level_1_user" do
      create(:geozone)
      user = create(:user)
      login_as(user)

      visit proposals_path

      expect(page.html).to include "level_1_user"
    end

    scenario "Usertype level_2_user" do
      create(:geozone)
      user = create(:user)
      login_as(user)

      visit account_path
      click_link "Verify my account"

      verify_residence

      fill_in "sms_phone", with: "611111111"
      click_button "Send"

      user = user.reload
      fill_in "sms_confirmation_code", with: user.sms_confirmation_code
      click_button "Send"

      expect(page.html).to include "level_2_user"
    end
  end

  context "Tracking events" do
    scenario "Verification: start census" do
      user = create(:user)
      login_as(user)

      visit account_path
      click_link "Verify my account"

      expect(page.html).to include "data-track-event-category=verification"
      expect(page.html).to include "data-track-event-action=start_census"
    end

    scenario "Verification: success census & start sms" do
      create(:geozone)
      user = create(:user)
      login_as(user)

      visit account_path
      click_link "Verify my account"

      verify_residence

      fill_in "sms_phone", with: "611111111"
      click_button "Send"

      expect(page.html).to include "data-track-event-category=verification"
      expect(page.html).to include "data-track-event-action=start_sms"
    end

    scenario "Verification: success sms" do
      create(:geozone)
      user = create(:user)
      login_as(user)

      visit account_path
      click_link "Verify my account"

      verify_residence

      fill_in "sms_phone", with: "611111111"
      click_button "Send"

      user = user.reload
      fill_in "sms_confirmation_code", with: user.sms_confirmation_code
      click_button "Send"

      expect(page.html).to include "data-track-event-category=verification"
      expect(page.html).to include "data-track-event-action=success_sms"
    end

    scenario "Verification: letter" do
      create(:geozone)
      user = create(:user)
      login_as(user)

      visit account_path
      click_link "Verify my account"

      verify_residence

      fill_in "sms_phone", with: "611111111"
      click_button "Send"

      user = user.reload
      fill_in "sms_confirmation_code", with: user.sms_confirmation_code
      click_button "Send"

      click_link "Send me a letter with the code"

      expect(page.html).to include "data-track-event-category=verification"
      expect(page.html).to include "data-track-event-action=start_letter"
    end
  end
end
