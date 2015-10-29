require 'rails_helper'

feature 'Account' do

  background do
    @user = create(:user, username: "Manuela Colau")
    login_as(@user)
  end

  scenario 'Show' do
    visit root_path

    click_link "My account"

    expect(current_path).to eq(account_path)

    expect(page).to have_selector("input[value='Manuela Colau']")
    expect(page).to have_selector(avatar('Manuela Colau'), count: 1)
  end

  scenario 'Show organization' do
    create(:organization, user: @user, name: "Manuela Corp")

    visit account_path

    expect(page).to have_selector("input[value='Manuela Corp']")
    expect(page).to_not have_selector("input[value='Manuela Colau']")

    expect(page).to have_selector(avatar('Manuela Corp'), count: 1)
  end

  scenario 'Edit' do
    visit account_path

    fill_in 'account_username', with: 'Larry Bird'
    check 'account_email_on_comment'
    check 'account_email_on_comment_reply'
    click_button 'Save changes'

    expect(page).to have_content "Changes saved"

    visit account_path

    expect(page).to have_selector("input[value='Larry Bird']")
    expect(page).to have_selector("input[id='account_email_on_comment'][value='1']")
    expect(page).to have_selector("input[id='account_email_on_comment_reply'][value='1']")
  end

  scenario 'Edit Organization' do
    create(:organization, user: @user, name: "Manuela Corp")
    visit account_path

    fill_in 'account_organization_attributes_name', with: 'Google'
    check 'account_email_on_comment'
    check 'account_email_on_comment_reply'
    click_button 'Save changes'

    expect(page).to have_content "Changes saved"

    visit account_path

    expect(page).to have_selector("input[value='Google']")
    expect(page).to have_selector("input[id='account_email_on_comment'][value='1']")
    expect(page).to have_selector("input[id='account_email_on_comment_reply'][value='1']")
  end

  scenario "Errors on edit" do
    visit account_path

    fill_in 'account_username', with: ''
    click_button 'Save changes'

    expect(page).to have_content error_message
  end

  scenario 'Errors editing credentials' do
    visit account_path

    click_link 'Change my credentials'
    click_button 'Update'

    expect(page).to have_content error_message
  end

  scenario 'Erasing account' do
    visit account_path

    click_link 'Erase my account'

    fill_in 'user_erase_reason', with: 'a test'

    click_button 'Erase my account'

    expect(page).to have_content "Goodbye! Your account has been cancelled. We hope to see you again soon."

    login_through_form_as(@user)

    expect(page).to have_content "Invalid email or password"
  end
end
