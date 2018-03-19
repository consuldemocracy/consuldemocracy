require 'rails_helper'

Rails.application.configure do
  config.action_controller.allow_forgery_protection = true
end

feature "Application" do

  let(:user)  { create(:user) }

  scenario 'protects from forgery on forms', :js do
    login_as(user)
    visit account_path

    fill_in 'account_username', with: 'Larry Bird'

    page.execute_script("$('input[name=authenticity_token]').attr('value','not_secure_token')")

    click_button 'Save changes'

    expect(page).to have_content "Invalid authenticity token, please try again."
  end

end
