require 'rails_helper'

feature 'Organizations' do

  scenario 'Organizations can be created' do
    user = User.organizations.where(email: 'green@peace.com').first
    expect(user).to_not be

    visit new_organization_registration_path

    fill_in 'user_organization_attributes_name',  with: 'Greenpeace'
    fill_in 'user_organization_attributes_responsible_name', with: 'Dorothy Stowe'
    fill_in 'user_email',                         with: 'green@peace.com'
    fill_in 'user_password',                      with: 'greenpeace'
    fill_in 'user_password_confirmation',         with: 'greenpeace'
    fill_in 'user_captcha', with: correct_captcha_text
    check 'user_terms_of_service'

    click_button 'Register'

    user = User.organizations.where(email: 'green@peace.com').first
    expect(user).to be
    expect(user).to be_organization
    expect(user.organization).to_not be_verified
  end

  scenario 'Errors on create' do
    visit new_organization_registration_path

    click_button 'Register'

    expect(page).to have_content error_message
  end

  scenario 'Shared links' do
    # visit new_user_registration_path
    # expect(page).to have_link "Sign up as an organization / collective"

    # visit new_organization_registration_path
    # expect(page).to have_link "Sign up"

    visit new_user_session_path

    expect(page).to have_link "Sign up"
    expect(page).to_not have_link "Sign up as an organization"
  end
end
