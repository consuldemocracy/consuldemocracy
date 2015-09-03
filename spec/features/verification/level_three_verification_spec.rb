require 'rails_helper'

feature 'Level three verification' do
  scenario 'Verification with residency and verified sms' do
    user = create(:user)

    verified_user = create(:verified_user,
                           document_number: '12345678Z',
                           document_type:   '1',
                           phone:           '611111111')

    login_as(user)

    visit account_path
    click_link 'Verify my account'

    verify_residence

    within("#verified_user_#{verified_user.id}_phone") do
      click_button "Send code"
    end

    expect(page).to have_content 'Security code confirmation'

    user = user.reload
    fill_in 'sms_confirmation_code', with: user.sms_confirmation_code
    click_button 'Send'

    expect(page).to have_content "Correct code. Your account is verified"

    expect(page).to_not have_link "Verify my account"
    expect(page).to have_content "Verified account"
  end

  scenario 'Verification with residency and verified email' do
    user = create(:user)

    verified_user = create(:verified_user,
                           document_number: '12345678Z',
                           document_type:   '1',
                           email:           'rock@example.com')

    login_as(user)

    visit account_path
    click_link 'Verify my account'

    verify_residence

    within("#verified_user_#{verified_user.id}_email") do
      click_button "Send code"
    end

    expect(page).to have_content 'We have send you a confirmation email to your email account: rock@example.com'

    sent_token = /.*email_verification_token=(.*)".*/.match(ActionMailer::Base.deliveries.last.body.to_s)[1]
    visit email_path(email_verification_token: sent_token)

    expect(page).to have_content "You are now a verified user"

    expect(page).to_not have_link "Verify my account"
    expect(page).to have_content "Verified account"
  end

  scenario 'Verification with residency and sms and letter' do

    user = create(:user)
    login_as(user)

    visit account_path
    click_link 'Verify my account'

    verify_residence

    fill_in 'sms_phone', with: "611111111"
    click_button 'Send'

    expect(page).to have_content 'Security code confirmation'

    user = user.reload
    fill_in 'sms_confirmation_code', with: user.sms_confirmation_code
    click_button 'Send'

    expect(page).to have_content 'Correct code'

    click_button "Send me a letter with the code"

    expect(page).to have_content "Thank you for requesting a maximum security code in a few days we will send it to the address on your census data."

    user.reload
    fill_in "letter_verification_code", with: user.letter_verification_code
    click_button "Send"

    expect(page).to have_content "Correct code. Your account is verified"
  end
end