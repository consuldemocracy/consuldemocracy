require 'rails_helper'

feature 'Level two verification' do

  scenario 'Verification with residency and sms' do
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
  end

end