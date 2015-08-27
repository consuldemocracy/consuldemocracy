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

    select 'Spanish ID', from: 'residence_document_type'
    fill_in 'residence_document_number', with: "12345678Z"
    select_date '31-December-1980', from: 'residence_date_of_birth'
    fill_in 'residence_postal_code', with: '28013'

    click_button 'Verify'

    expect(page).to have_content 'Residence verified'

    within("#verified_user_#{verified_user.id}_phone") do
      click_button "Send"
    end

    expect(page).to have_content 'Security code confirmation'

    user = user.reload
    fill_in 'sms_confirmation_code', with: user.sms_confirmation_code
    click_button 'Send'

    expect(page).to have_content 'Correct code'

    expect(page).to have_content "You are now a verified user"

    expect(page).to_not have_link "Verify my account"
    expect(page).to have_content "You are a level 3 user"
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

    select 'Spanish ID', from: 'residence_document_type'
    fill_in 'residence_document_number', with: "12345678Z"
    select_date '31-December-1980', from: 'residence_date_of_birth'
    fill_in 'residence_postal_code', with: '28013'

    click_button 'Verify'

    expect(page).to have_content 'Residence verified'

    within("#verified_user_#{verified_user.id}_email") do
      click_button "Send"
    end

    expect(page).to have_content 'We have send you a confirmation email to your email account: rock@example.com'

    sent_token = /.*email_verification_token=(.*)".*/.match(ActionMailer::Base.deliveries.last.body.to_s)[1]
    visit email_path(email_verification_token: sent_token)

    expect(page).to have_content "You are now a verified user"

    expect(page).to_not have_link "Verify my account"
    expect(page).to have_content "You are a level 3 user"
  end

  scenario 'Verification with residency and sms and letter' do

    user = create(:user)
    login_as(user)

    visit account_path
    click_link 'Verify my account'

    select 'Spanish ID', from: 'residence_document_type'
    fill_in 'residence_document_number', with: "12345678Z"
    select_date '31-December-1980', from: 'residence_date_of_birth'
    fill_in 'residence_postal_code', with: '28013'

    click_button 'Verify'

    expect(page).to have_content 'Residence verified'

    fill_in 'sms_phone', with: "611111111"
    click_button 'Send'

    expect(page).to have_content 'Security code confirmation'

    user = user.reload
    fill_in 'sms_confirmation_code', with: user.sms_confirmation_code
    click_button 'Send'

    expect(page).to have_content 'Correct code'

    click_button "Send me a letter"

    expect(page).to have_content "You will receive a letter to your home address"
  end
end