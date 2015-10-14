require 'rails_helper'

feature 'Verify Letter' do

  scenario 'Verify' do
    user = create(:user, residence_verified_at: Time.now,
                         confirmed_phone:       "611111111",
                         letter_sent_at:        1.day.ago)

    login_as(user)
    visit new_letter_path

    click_link "Request a letter"

    expect(page).to have_content "Before voting you'll receive a letter whith the instructions for verify your account."
  end

  scenario 'Go to office instead of send letter' do
    user = create(:user, residence_verified_at: Time.now,
                         confirmed_phone:       "611111111",
                         letter_sent_at:        1.day.ago)

    login_as(user)
    visit new_letter_path

    expect(page).to have_link "Office of Citizen", href: "http://www.madrid.es/portales/munimadrid/es/Inicio/El-Ayuntamiento/Atencion-al-ciudadano/Oficinas-de-Atencion-al-Ciudadano?vgnextfmt=default&vgnextchannel=5b99cde2e09a4310VgnVCM1000000b205a0aRCRD"
  end

  scenario 'Errors on verification code' do
    user = create(:user, residence_verified_at: Time.now,
                         confirmed_phone:       "611111111",
                         letter_sent_at:        1.day.ago)

    login_as(user)
    visit new_letter_path

    click_link "Request a letter"
    expect(page).to have_content "Before voting you'll receive a letter whith the instructions for verify your account."

  end

  scenario "Deny access unless verified residence" do
    user = create(:user)

    login_as(user)
    visit new_letter_path

    expect(page).to have_content 'You have not yet confirmed your residence'
    expect(current_path).to eq(new_residence_path)
  end

  scenario "Deny access unless verified phone/email" do
    user = create(:user, residence_verified_at: Time.now)

    login_as(user)
    visit new_letter_path

    expect(page).to have_content 'You have not yet enter the confirmation code'
    expect(current_path).to eq(new_sms_path)
  end
end
