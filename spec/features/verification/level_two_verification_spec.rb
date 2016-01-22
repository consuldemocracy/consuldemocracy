require 'rails_helper'

feature 'Level two verification' do
  before do
    expect(Census).to receive(:new)
                       .with(a_hash_including(document_type: "dni",
                                              document_number: "12345678Z"))
                       .and_return double(:valid? => true)

  end

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

    expect(page).to have_content 'Code correct'
  end

end
