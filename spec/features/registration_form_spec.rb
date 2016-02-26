require 'rails_helper'

feature 'Registration form' do

  scenario 'username is not available', :js do
    user = create(:user)

    visit new_user_registration_path
    expect(page).to_not have_content I18n.t("devise_views.users.registrations.new.username_is_not_available")

    fill_in "user_username", with: user.username
    check 'user_terms_of_service'

    expect(page).to have_content I18n.t("devise_views.users.registrations.new.username_is_not_available")
  end

  scenario 'username is available', :js do
    visit new_user_registration_path
    expect(page).to_not have_content I18n.t("devise_views.users.registrations.new.username_is_available")

    fill_in "user_username", with: "available username"
    check 'user_terms_of_service'

    expect(page).to have_content I18n.t("devise_views.users.registrations.new.username_is_available")
  end

  scenario 'do not save blank redeemable codes' do
    visit new_user_registration_path(use_redeemable_code: 'true')

    fill_in 'user_username',              with: "NewUserWithCode77"
    fill_in 'user_email',                 with: "new@madrid.es"
    fill_in 'user_password',              with: "password"
    fill_in 'user_password_confirmation', with: "password"
    fill_in 'user_redeemable_code',       with: "            "
    fill_in 'user_captcha',               with: correct_captcha_text
    check 'user_terms_of_service'

    click_button 'Register'

    expect(page).to have_content "Thank you for registering"

    new_user = User.last
    expect(new_user.username).to eq("NewUserWithCode77")
    expect(new_user.redeemable_code).to be_nil
  end

end
