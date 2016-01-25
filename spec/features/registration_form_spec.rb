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

end
