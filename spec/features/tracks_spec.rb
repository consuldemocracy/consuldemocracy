require 'rails_helper'

feature 'Tracking' do

  context 'Custom variable' do

     scenario 'Usertype anonymous' do
      visit proposals_path

      expect(page.html).to include I18n.t("tracking.user_data.user_type.anonymous")
    end

    scenario 'Usertype level_1_user' do
      user = create(:user)
      login_as(user)

      visit proposals_path

      expect(page.html).to include I18n.t("tracking.user_data.user_type.level_one")
    end

    scenario 'Usertype level_2_user', :js do
      create(:geozone)
      user = create(:user)
      login_as(user)

      visit account_path
      click_link 'Verify my account'

      verify_residence

      fill_in 'sms_phone', with: "611111111"
      click_button 'Send'

      user = user.reload
      fill_in 'sms_confirmation_code', with: user.sms_confirmation_code
      click_button 'Send'
      expect(page.html).to include I18n.t("tracking.user_data.user_type.level_two")
    end
  end

  context 'Tracking events' do
    scenario 'Verification: start residence verification', :js do
      create(:geozone)
      user = create(:user)
      login_as(user)

      visit account_path

      click_link 'Verify my account'

      expect(page).to have_css('meta[data-track-event-category="Verification"]', visible: false)
      expect(page.html).to include 'data-track-event-action="Start residence verification"'
    end

    scenario 'Verification: success residence verification' do
      create(:geozone)
      user = create(:user)
      login_as(user)

      visit account_path
      click_link 'Verify my account'

      verify_residence

        expect(page.html).to include 'data-track-event-category="Verification"'
        expect(page.html).to include 'data-track-event-action="Residence verified"'
    end

    scenario 'Verification: start phone verification' do
      create(:geozone)
      user = create(:user)
      login_as(user)

      visit account_path
      click_link 'Verify my account'

      verify_residence

      fill_in 'sms_phone', with: "611111111"
      click_button 'Send'

      expect(page.html).to include 'data-track-event-category="Verification"'
      expect(page.html).to include 'data-track-event-action="Start phone verification"'
    end

    scenario 'Verification: success phone verification' do
      create(:geozone)
      user = create(:user)
      login_as(user)

      visit account_path
      click_link 'Verify my account'

      verify_residence

      fill_in 'sms_phone', with: "611111111"
      click_button 'Send'

      user = user.reload
      fill_in 'sms_confirmation_code', with: user.sms_confirmation_code
      click_button 'Send'

      expect(page.html).to include 'data-track-event-category="Verification"'
      expect(page.html).to include 'data-track-event-action="Phone verified"'
    end

    scenario 'Verification: letter code' do
      create(:geozone)
      user = create(:user)
      login_as(user)

      visit account_path
      click_link 'Verify my account'

      verify_residence

      fill_in 'sms_phone', with: "611111111"
      click_button 'Send'

      user = user.reload
      fill_in 'sms_confirmation_code', with: user.sms_confirmation_code
      click_button 'Send'

      click_link "Send me a letter with the code"

      expect(page.html).to include 'data-track-event-category="Verification"'
      expect(page.html).to include 'data-track-event-action="Requested sending letter"'
    end
  end
end
