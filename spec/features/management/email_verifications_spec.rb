require 'rails_helper'

feature 'EmailVerifications' do

  scenario 'Verifying a level 1 user via email' do
    login_as_manager

    user = create(:user)

    visit management_document_verifications_path
    fill_in 'document_verification_document_number', with: '12345678Z'
    click_button 'Check document'

    expect(page).to have_content "Please introduce the email used on the account"

    fill_in 'email_verification_email', with: user.email
    click_button 'Send verification email'

    expect(page).to have_content("In order to completely verify this user, it is necessary that the user clicks on a link")

    user.reload

    login_as(user)

    sent_token = /.*email_verification_token=(.*)&amp;.*".*/.match(ActionMailer::Base.deliveries.last.body.to_s)[1]

    visit date_of_birth_email_path(email_verification_token: sent_token, id: user.id)

    expect(page).to have_content "Confirm your account"

    within('#date_day') do
      find("option[value='1']").select_option
    end
    
    within('#date_month') do
      find("option[value='1']").select_option
    end
    
    within('#date_year') do
      find("option[value='#{16.years.ago.year}']").select_option
    end

    click_button "Confirm my account"

    expect(page).to have_content "You are a verified user"

    expect(page).not_to have_link "Verify my account"
    expect(page).to have_content "Account verified"

    expect(user.reload.document_number).to eq('12345678Z')
    expect(user).to be_level_three_verified
    expect(user.date_of_birth.to_date).to eq(DateTime.new(16.years.ago.year, 1, 1, 0, 0, 0).in_time_zone.to_date)
  end

end
