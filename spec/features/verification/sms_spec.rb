require 'rails_helper'

feature 'SMS Verification' do

  scenario 'Verify' do
    user = create(:user, residence_verified_at: Time.now)
    login_as(user)

    visit new_sms_path

    fill_in 'sms_phone', with: "611111111"
    click_button 'Send'

    expect(page).to have_content 'Security code confirmation'

    user = user.reload
    fill_in 'sms_confirmation_code', with: user.sms_confirmation_code
    click_button 'Send'

    expect(page).to have_content 'Correct code'
  end

  scenario 'Errors on phone number' do
    user = create(:user, residence_verified_at: Time.now)
    login_as(user)

    visit new_sms_path

    click_button 'Send'

    expect(page).to have_content error_message
  end

  scenario 'Errors on verification code' do
    user = create(:user, residence_verified_at: Time.now)
    login_as(user)

    visit new_sms_path

    fill_in 'sms_phone', with: "611111111"
    click_button 'Send'

    expect(page).to have_content 'Security code confirmation'

    click_button 'Send'

    expect(page).to have_content 'Incorrect confirmation code'
  end

  scenario 'Deny access unless residency verified' do
    user = create(:user)
    login_as(user)

    visit new_sms_path

    expect(page).to have_content 'You have not yet confirmed your residence'
    expect(URI.parse(current_url).path).to eq(new_residence_path)
  end

  scenario '3 tries allowed' do
    user = create(:user, residence_verified_at: Time.now)
    login_as(user)

    visit new_sms_path

    3.times do
      fill_in 'sms_phone', with: "611111111"
      click_button 'Send'
      click_link 'Click here to send the confirmation code again'
    end

    expect(page).to have_content 'You have reached the maximum number of sms verification tries'
    expect(URI.parse(current_url).path).to eq(account_path)

    visit new_sms_path
    expect(page).to have_content 'You have reached the maximum number of sms verification tries'
    expect(URI.parse(current_url).path).to eq(account_path)
  end

end