require 'rails_helper'

feature 'Verify Letter' do

  scenario 'Verify' do
    user = create(:user, residence_verified_at: Time.now, confirmed_phone: "611111111")

    login_as(user)
    visit new_letter_path

    click_button "Send me a letter with the code"

    expect(page).to have_content "Thank you for requesting a maximum security code in a few days we will send it to the address on your census data."

    user.reload
    fill_in "letter_verification_code", with: user.letter_verification_code
    click_button "Send"

    expect(page).to have_content "Correct code. Your account is verified"
  end

  scenario 'Go to office instead of send letter' do
    user = create(:user, residence_verified_at: Time.now, confirmed_phone: "611111111")

    login_as(user)
    visit new_letter_path

    expect(page).to have_link "See Office of Citizen", href: "http://www.madrid.es/portales/munimadrid/es/Inicio/El-Ayuntamiento/Atencion-al-ciudadano/Oficinas-de-Atencion-al-Ciudadano?vgnextfmt=default&vgnextchannel=5b99cde2e09a4310VgnVCM1000000b205a0aRCRD"
  end

  scenario 'Errors on verification code' do
    user = create(:user, residence_verified_at: Time.now, confirmed_phone: "611111111")

    login_as(user)
    visit new_letter_path

    click_button "Send me a letter with the code"
    expect(page).to have_content "Thank you for requesting a maximum security code in a few days we will send it to the address on your census data."

    fill_in "letter_verification_code", with: "1"
    click_button "Send"

    expect(page).to have_content "Incorrect confirmation code"
  end

  scenario "Error accessing address from CensusApi" do
    user = create(:user, residence_verified_at: Time.now, confirmed_phone: "611111111")

    login_as(user)
    visit new_letter_path

    allow_any_instance_of(CensusApi).to receive(:address).and_return(nil)

    click_button "Send me a letter with the code"

    expect(page).to have_content "We could not verify your address with the Census please try again later"
  end

  scenario "Deny access unless verified residence" do
    user = create(:user)

    login_as(user)
    visit new_letter_path

    expect(page).to have_content 'You have not yet confirmed your residence'
    expect(URI.parse(current_url).path).to eq(new_residence_path)
  end

  scenario "Deny access unless verified phone/email" do
    user = create(:user, residence_verified_at: Time.now)

    login_as(user)
    visit new_letter_path

    expect(page).to have_content 'You have not yet enter the confirmation code'
    expect(URI.parse(current_url).path).to eq(new_sms_path)
  end

end
