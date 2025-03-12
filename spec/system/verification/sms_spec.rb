require "rails_helper"

describe "SMS Verification" do
  scenario "Verify" do
    allow_any_instance_of(Verification::Sms).to receive(:generate_confirmation_code).and_return("5678")
    user = create(:user, residence_verified_at: Time.current)
    login_as(user)

    visit new_sms_path
    confirm_phone(code: "5678")

    expect(page).to have_content "Code correct"
  end

  scenario "Errors on phone number" do
    user = create(:user, residence_verified_at: Time.current)
    login_as(user)

    visit new_sms_path

    click_button "Send"

    expect(page).to have_content error_message("phone")
  end

  scenario "Errors on verification code" do
    user = create(:user, residence_verified_at: Time.current)
    login_as(user)

    visit new_sms_path

    fill_in "sms_phone", with: "611111111"
    click_button "Send"

    expect(page).to have_content "Security code confirmation"

    click_button "Send"

    expect(page).to have_content "Incorrect confirmation code"
  end

  scenario "Deny access unless residency verified" do
    user = create(:user)
    login_as(user)

    visit new_sms_path

    expect(page).to have_content "You have not yet confirmed your residency"
    expect(page).to have_current_path(new_residence_path)
  end

  scenario "5 tries allowed" do
    user = create(:user, residence_verified_at: Time.current)
    login_as(user)

    visit new_sms_path

    5.times do
      fill_in "sms_phone", with: "611111111"
      click_button "Send"

      expect(page).to have_content "Enter the confirmation code sent to you by text message"

      click_link "Click here to send it again"

      expect(page).not_to have_content "Enter the confirmation code sent to you by text message"
    end

    expect(page).to have_content "You have reached the maximum number of attempts. Please try again later."
    expect(page).to have_current_path(account_path)

    visit root_path

    expect(page).not_to have_content "You have reached the maximum number of attempts"

    visit new_sms_path
    expect(page).to have_content "You have reached the maximum number of attempts. Please try again later."
    expect(page).to have_current_path(account_path)
  end
end
