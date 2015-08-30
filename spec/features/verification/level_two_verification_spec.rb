require 'rails_helper'

feature 'Level two verification' do

  scenario 'Verification with residency and sms' do
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
  end

end