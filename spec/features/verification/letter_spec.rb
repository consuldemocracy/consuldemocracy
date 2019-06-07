require "rails_helper"

feature "Verify Letter" do

  scenario "Request a letter" do
    user = create(:user, residence_verified_at: Time.current,
                         confirmed_phone:       "611111111")

    login_as(user)
    visit new_letter_path

    click_link "Send me a letter with the code"

    expect(page).to have_content "Thank you for requesting your maximum security code (only required for the final votes). In a few days"\
                                 " we will send it to the address featuring in the data we have on file."

    user.reload

    expect(user.letter_requested_at).to be
    expect(user.letter_verification_code).to be
  end

  scenario "Go to office instead of send letter" do
    Setting["verification_offices_url"] = "http://offices.consul"
    user = create(:user, residence_verified_at: Time.current,
                         confirmed_phone:       "611111111")

    login_as(user)
    visit new_letter_path

    expect(page).to have_link "Citizen Support Offices", href: "http://offices.consul"
  end

  scenario "Deny access unless verified residence" do
    user = create(:user)

    login_as(user)
    visit new_letter_path

    expect(page).to have_content "You have not yet confirmed your residency"
    expect(page).to have_current_path(new_residence_path)
  end

  scenario "Deny access unless verified phone/email" do
    user = create(:user, residence_verified_at: Time.current)

    login_as(user)
    visit new_letter_path

    expect(page).to have_content "You have not yet entered the confirmation code"
    expect(page).to have_current_path(new_sms_path)
  end

  context "Code verification" do

    scenario "Valid verification user logged in" do
      user = create(:user, residence_verified_at: Time.current,
                           confirmed_phone:       "611111111",
                           letter_verification_code: "123456")

      login_as(user)
      visit edit_letter_path

      fill_in "verification_letter_email", with: user.email
      fill_in "verification_letter_password", with: user.password
      fill_in "verification_letter_verification_code", with: user.letter_verification_code
      click_button "Verify my account"

      expect(page).to have_content "Code correct. Your account is now verified"
      expect(page).to have_current_path(account_path)
    end

    scenario "Valid verification of user failing to add trailing zeros" do
      user = create(:user, residence_verified_at: Time.current,
                           confirmed_phone:       "611111111",
                           letter_verification_code: "012345")

      login_as(user)
      visit edit_letter_path

      fill_in "verification_letter_email", with: user.email
      fill_in "verification_letter_password", with: user.password
      fill_in "verification_letter_verification_code", with: "12345"
      click_button "Verify my account"

      expect(page).to have_content "Account verified"
      expect(page).to have_current_path(account_path)
    end

    scenario "Valid verification user not logged in" do
      user = create(:user, residence_verified_at: Time.current,
                           confirmed_phone:       "611111111",
                           letter_verification_code: "123456")

      visit edit_letter_path

      fill_in "verification_letter_email", with: user.email
      fill_in "verification_letter_password", with: user.password
      fill_in "verification_letter_verification_code", with: user.letter_verification_code
      click_button "Verify my account"

      expect(page).to have_content "Code correct. Your account is now verified"
      expect(page).to have_current_path(account_path)
    end

    scenario "Error messages on authentication" do
      visit edit_letter_path

      click_button "Verify my account"

      expect(page).to have_content "Invalid email or password."
    end

    scenario "Error messages on verification" do
      user = create(:user, residence_verified_at: Time.current,
                           confirmed_phone:       "611111111")

      visit edit_letter_path
      fill_in "verification_letter_email", with: user.email
      fill_in "verification_letter_password", with: user.password
      click_button "Verify my account"

      expect(page).to have_content "can't be blank"
    end

    scenario "6 tries allowed" do
      user = create(:user, residence_verified_at:    Time.current,
                           confirmed_phone:          "611111111",
                           letter_verification_code: "123456")

      visit edit_letter_path

      6.times do
        fill_in "verification_letter_email", with: user.email
        fill_in "verification_letter_password", with: user.password
        fill_in "verification_letter_verification_code", with: "1"
        click_button "Verify my account"
      end

      expect(page).to have_content "You have reached the maximum number of attempts. Please try again later."
      expect(page).to have_current_path(account_path)
    end

  end
end
