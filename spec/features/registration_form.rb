require 'rails_helper'

feature 'Registration form' do

  scenario 'does not submit if user is not validated', :js do
    user = create(:user)

    visit new_user_registration_path
    fill_in "user_username", with: user.username
    fill_in "user_email", with: "#{user.username}@domain.com"
    fill_in "user_password", with: "password"
    fill_in "user_password_confirmation", with: "password"
    fill_in "user_captcha", with: correct_captcha_text
    check 'user_terms_of_service'

    click_button 'Register'

    expect(page).to_not have_content "You have been sent a message containing a verification link"

    expect(page).to have_content "has already been taken"
    expect(find_field("Password").value).to eq "password"
    expect(find_field("Confirm password").value).to eq "password"
    expect(find_field("Captcha").value).to eq correct_captcha_text
  end

  scenario 'does submit if user is validated', :js do
    visit new_user_registration_path
    fill_in "user_username", with: "username"
    fill_in "user_email", with: "username@domain.com"
    fill_in "user_password", with: "password"
    fill_in "user_password_confirmation", with: "password"
    fill_in "user_captcha", with: correct_captcha_text
    check 'user_terms_of_service'

    click_button 'Register'

    expect(page).to have_content "You have been sent a message containing a verification link"
  end

end
