require 'rails_helper'

feature 'Tracking' do

  context 'Custom variable' do

     scenario 'Usertype anonymous' do
      visit proposals_path

      expect(page.html).to include "Anónimo"
    end

    scenario 'Usertype level_1_user' do
      user = create(:user)
      login_as(user)

      visit proposals_path

      expect(page.html).to include "level_1_user"
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
      expect(page.html).to include "level_2_user"
    end
  end

  context 'Tracking events' do
    scenario 'Verification: start residence verification', :js do
      create(:geozone)
      user = create(:user)
      login_as(user)

      visit account_path

      click_link 'Verify my account'
      save_and_open_page
  
      #expect(page.html).to include "data-track-event-category=\"Verificación\""
      #expect(page.html).to include "data-track-event-action=\"Inicio_verificación_de_residencia\""

      expect(page).to have_css('meta[data-track-event-category="Verificación"]', visible: false)
      puts page.html
    end

    scenario 'Verification: success residence verification' do
      create(:geozone)
      user = create(:user)
      login_as(user)

      visit account_path
      click_link 'Verify my account'

      verify_residence

        expect(page.html).to include "data-track-event-category=Verificación"
        expect(page.html).to include "data-track-event-action=Residencia_verificada"
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

      expect(page.html).to include "data-track-event-category=Verificación"
      expect(page.html).to include "data-track-event-action=Inicio_verificación_de_teléfono"
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

      expect(page.html).to include "data-track-event-category=Verificación"
      expect(page.html).to include "data-track-event-action=Teléfono_verificado"
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

      expect(page.html).to include "data-track-event-category=Verificación"
      expect(page.html).to include "data-track-event-action=Solicitado_envio_de_código_por_carta"
    end
  end
end
