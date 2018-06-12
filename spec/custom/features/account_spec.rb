require 'rails_helper'

feature 'Account' do

  background do
    @user = create(:user, username: "Manuela Colau")
    login_as(@user)
    Setting['feature.articles'] = true
  end

  after do
    Setting['feature.articles'] = nil
  end

  scenario 'Show' do
    visit root_path

    click_link("My account", match: :first)

    expect(page).to have_current_path(account_path, ignore_query: true)

    expect(page).to have_selector("input[value='Manuela Colau']")
    expect(page).to have_selector(avatar('Manuela Colau'), count: 1)
  end

  scenario 'Edit email address' do
    visit account_path

    click_link "Change my credentials"
    fill_in "user_email", with: "new_user_email@example.com"
    fill_in "user_password", with: "new_password"
    fill_in "user_password_confirmation", with: "new_password"
    fill_in "user_current_password", with: "judgmentday"

    click_button "Update"

    notice = 'Your account has been updated successfully;'\
             ' however, we need to verify your new email address.'\
             ' Please check your email and click on the link to'\
             ' complete the confirmation of your new email address.'
    expect(page).to have_content notice

    email = open_last_email
    visit_in_email("Confirm my account")

    logout
    visit root_path
    click_link("Sign in", match: :first)
    fill_in "user_login", with: "new_user_email@example.com"
    fill_in "user_password", with: "new_password"
    click_button "Enter"

    expect(page).to have_content "You have been signed in successfully."

    visit account_path
    click_link "Change my credentials"
    expect(page).to have_selector("input[value='new_user_email@example.com']")
  end


  scenario "Errors on edit" do
    visit account_path

    fill_in 'account_username', with: ''
    fill_in 'account_lastname', with: ''
    click_button 'Save changes'

    expect(page).to have_content error_message
  end

  scenario 'Errors editing credentials' do
    visit root_path

    click_link('My account', match: :first)

    expect(page).to have_current_path(account_path, ignore_query: true)

    expect(page).to have_link('Change my credentials')
    click_link 'Change my credentials'
    click_button 'Update'

    expect(page).to have_content error_message
  end

end
