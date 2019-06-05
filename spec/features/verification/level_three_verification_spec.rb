require "rails_helper"

feature "Level three verification" do
  scenario "Verification with residency and verified sms" do
    create(:geozone)
    user = create(:user)

    verified_user = create(:verified_user,
                           document_number: "12345678Z",
                           document_type:   "1",
                           phone:           "611111111")

    login_as(user)

    visit account_path
    click_link "Verify my account"

    verify_residence

    within("#verified_user_#{verified_user.id}_phone") do
      click_button "Send code"
    end

    expect(page).to have_content "Security code confirmation"

    user = user.reload
    fill_in "sms_confirmation_code", with: user.sms_confirmation_code
    click_button "Send"

    expect(page).to have_content "Code correct. Your account is now verified"

    expect(page).not_to have_link "Verify my account"
    expect(page).to have_content "Account verified"
  end

  scenario "Verification with residency and verified email" do
    create(:geozone)
    user = create(:user)

    verified_user = create(:verified_user,
                           document_number: "12345678Z",
                           document_type:   "1",
                           email:           "rock@example.com")

    login_as(user)

    visit account_path
    click_link "Verify my account"

    verify_residence

    within("#verified_user_#{verified_user.id}_email") do
      click_button "Send code"
    end

    expect(page).to have_content "We have sent a confirmation email to your account: rock@example.com"

    sent_token = /.*email_verification_token=(.*)".*/.match(ActionMailer::Base.deliveries.last.body.to_s)[1]
    visit email_path(email_verification_token: sent_token)

    expect(page).to have_content "You are a verified user"

    expect(page).not_to have_link "Verify my account"
    expect(page).to have_content "Account verified"
  end

  scenario "Verification with residency and sms and letter" do
    create(:geozone)
    user = create(:user)
    login_as(user)

    visit account_path
    click_link "Verify my account"

    verify_residence

    fill_in "sms_phone", with: "611111111"
    click_button "Send"

    expect(page).to have_content "Security code confirmation"

    user = user.reload
    fill_in "sms_confirmation_code", with: user.sms_confirmation_code
    click_button "Send"

    expect(page).to have_content "Code correct"

    click_link "Send me a letter with the code"

    expect(page).to have_content "Thank you for requesting your maximum security code (only required for the final votes)."\
                                 " In a few days we will send it to the address featuring in the data we have on file."
  end
end
