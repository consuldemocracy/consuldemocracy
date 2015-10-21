require 'rails_helper'

feature 'Verify Letter' do

  scenario 'Request a letter' do
    user = create(:user, residence_verified_at: Time.now,
                         confirmed_phone:       "611111111")

    login_as(user)
    visit new_letter_path

    click_link "Request a letter"

    expect(page).to have_content "Before voting you'll receive a letter whith the instructions for verify your account."

    user.reload

    expect(user.letter_requested_at).to be
    expect(user.letter_verification_code).to be
  end

  scenario 'Go to office instead of send letter' do
    user = create(:user, residence_verified_at: Time.now,
                         confirmed_phone:       "611111111")

    login_as(user)
    visit new_letter_path

    expect(page).to have_link "Office of Citizen", href: "http://www.madrid.es/portales/munimadrid/es/Inicio/El-Ayuntamiento/Atencion-al-ciudadano/Oficinas-de-Atencion-al-Ciudadano?vgnextfmt=default&vgnextchannel=5b99cde2e09a4310VgnVCM1000000b205a0aRCRD"
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

  context "Code verification" do

    scenario "Valid verification user logged in" do
      user = create(:user, residence_verified_at: Time.now,
                           confirmed_phone:       "611111111",
                           letter_verification_code: "123456")

      login_as(user)
      visit edit_letter_path

      fill_in "verification_letter_email", with: user.email
      fill_in "verification_letter_password", with: user.password
      fill_in "verification_letter_verification_code", with: user.letter_verification_code
      click_button "Verify my account"

      expect(page).to have_content "Your account has been verified"
      expect(current_path).to eq(account_path)
    end

    scenario "Valid verification user not logged in" do
      user = create(:user, residence_verified_at: Time.now,
                           confirmed_phone:       "611111111",
                           letter_verification_code: "123456")

      visit edit_letter_path

      fill_in "verification_letter_email", with: user.email
      fill_in "verification_letter_password", with: user.password
      fill_in "verification_letter_verification_code", with: user.letter_verification_code
      click_button "Verify my account"

      expect(page).to have_content "Your account has been verified"
      expect(current_path).to eq(account_path)
    end

    scenario "Error messages on authentication" do
      visit edit_letter_path

      click_button "Verify my account"

      expect(page).to have_content "Invalid email or password."
    end

    scenario "Error messages on verification" do
      user = create(:user, residence_verified_at: Time.now,
                           confirmed_phone:       "611111111")

      visit edit_letter_path
      fill_in "verification_letter_email", with: user.email
      fill_in "verification_letter_password", with: user.password
      click_button "Verify my account"

      expect(page).to have_content "can't be blank"
    end

    scenario '6 tries allowed' do
      user = create(:user, residence_verified_at:    Time.now,
                           confirmed_phone:          "611111111",
                           letter_verification_code: "123456")

      visit edit_letter_path

      6.times do
        fill_in "verification_letter_email", with: user.email
        fill_in "verification_letter_password", with: user.password
        fill_in "verification_letter_verification_code", with: "1"
        click_button "Verify my account"
      end

      expect(page).to have_content "You have reached the maximum number of verification tries. Please try again later."
      expect(current_path).to eq(account_path)
    end

  end
end
