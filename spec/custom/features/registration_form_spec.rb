require 'rails_helper'

feature 'Registration form' do

  scenario 'do not save blank redeemable codes' do
    visit new_user_registration_path(use_redeemable_code: 'true')

    fill_in 'user_username',              with: "NewUserWithCode77"
    fill_in 'user_firstname',             with: "NewUserWithCode77"
    fill_in 'user_lastname',              with: "NewUserWithCode77"
    fill_in 'user_email',                 with: "new@consul.dev"
    fill_in 'user_password',              with: "password"
    fill_in 'user_password_confirmation', with: "password"
    fill_in 'user_redeemable_code',       with: "            "
    fill_in 'user_postal_code',           with: "11000"
    select "1997", from: "user_date_of_birth_1i"
    select "January", from: "user_date_of_birth_2i"
    select "10", from: "user_date_of_birth_3i"
    check 'user_terms_of_service'

    click_button 'register-btn'

    expect(page).to have_content I18n.t("devise_views.users.registrations.success.title")

    new_user = User.last
    expect(new_user.username).to eq("NewUserWithCode77")
    expect(new_user.redeemable_code).to be_nil
  end

  scenario 'Create with invisible_captcha honeypot field' do
    visit new_user_registration_path

    fill_in 'user_username',              with: "robot"
    fill_in 'user_firstname',             with: "robot"
    fill_in 'user_lastname',              with: "robot"
    fill_in 'user_family_name',           with: 'This is the honeypot field'
    fill_in 'user_email',                 with: 'robot@robot.com'
    fill_in 'user_password',              with: 'destroyallhumans'
    fill_in 'user_password_confirmation', with: 'destroyallhumans'
    fill_in 'user_postal_code',           with: "11000"
    select "1997", from: "user_date_of_birth_1i"
    select "January", from: "user_date_of_birth_2i"
    select "10", from: "user_date_of_birth_3i"
    check 'user_terms_of_service'

    click_button 'register-btn'

    expect(page.status_code).to eq(200)
    expect(page.html).to be_empty
    expect(page).to have_current_path(user_registration_path)
  end

  scenario 'Create organization too fast' do
    allow(InvisibleCaptcha).to receive(:timestamp_threshold).and_return(Float::INFINITY)
    visit new_user_registration_path

    fill_in 'user_username',              with: "robot"
    fill_in 'user_family_name',           with: 'This is the honeypot field'
    fill_in 'user_email',                 with: 'robot@robot.com'
    fill_in 'user_password',              with: 'destroyallhumans'
    fill_in 'user_password_confirmation', with: 'destroyallhumans'
    check 'user_terms_of_service'

    click_button 'register-btn'

    expect(page).to have_content I18n.t("invisible_captcha.timestamp_error_message")

    expect(page).to have_current_path(new_user_registration_path)
  end

  scenario 'Autofill username and user is verified' do
    visit new_user_registration_path

    fill_in 'user_firstname',             with: "Tata"
    fill_in 'user_lastname',              with: "Yoyo"
    fill_in 'user_email',                 with: "new@consul.dev"
    fill_in 'user_password',              with: "password"
    fill_in 'user_password_confirmation', with: "password"
    fill_in 'user_postal_code',           with: "11000"
    select "1997", from: "user_date_of_birth_1i"
    select "January", from: "user_date_of_birth_2i"
    select "10", from: "user_date_of_birth_3i"
    check 'user_terms_of_service'

    click_button 'register-btn'

    expect(page).to have_content I18n.t("devise_views.users.registrations.success.title")

    new_user = User.last
    expect(new_user.username).to eq("Yoyo Tata")
    expect(new_user.level_two_verified?).to eq(true)
    expect(new_user.level_three_verified?).to eq(true)
  end

end
