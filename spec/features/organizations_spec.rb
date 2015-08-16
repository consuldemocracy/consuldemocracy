require 'rails_helper'

feature 'Organizations' do

  scenario 'Organizations can be created' do
    user = User.organizations.where(email: 'green@peace.com').first
    expect(user).to_not be

    visit new_organization_registration_path

    fill_in 'user_organization_attributes_name',  with: 'Greenpeace'
    fill_in 'user_email',                         with: 'green@peace.com'
    fill_in 'user_password',                      with: 'greenpeace'
    fill_in 'user_password_confirmation',         with: 'greenpeace'

    click_button 'Sign up'

    user = User.organizations.where(email: 'green@peace.com').first
    expect(user).to be
    expect(user).to be_organization
    expect(user.organization).to_not be_verified
  end

  scenario "Organization fields are validated" do
    visit new_organization_registration_path
    click_button 'Sign up'

    expect(page).to have_content "Email can't be blank"
    expect(page).to have_content "Password can't be blank"
    expect(page).to have_content "Organization name can't be blank"
  end
end
