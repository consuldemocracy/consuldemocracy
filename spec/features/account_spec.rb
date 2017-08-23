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
    uncheck 'account_email_digest'
    uncheck 'account_email_on_direct_message'
    click_button 'Save changes'

    expect(page).to have_content "Changes saved"

    visit account_path

    expect(page).to have_selector("input[value='Larry Bird']")
    expect(find("#account_email_on_comment")).to be_checked
    expect(find("#account_email_on_comment_reply")).to be_checked
    expect(find("#account_email_digest")).to_not be_checked
    expect(find("#account_email_on_direct_message")).to_not be_checked
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
    expect(find("#account_email_on_comment")).to be_checked
    expect(find("#account_email_on_comment_reply")).to be_checked
  end

  context "Option to display badge for official position" do

    scenario "Users with official position of level 1" do
      official_user = create(:user, official_level: 1)

      login_as(official_user)
      visit account_path

      check 'account_official_position_badge'
      click_button 'Save changes'
      expect(page).to have_content "Changes saved"

      visit account_path
      expect(find("#account_official_position_badge")).to be_checked
    end

    scenario "Users with official position of level 2 and above" do
      official_user2 = create(:user, official_level: 2)
      official_user3 = create(:user, official_level: 3)

      login_as(official_user2)
      visit account_path

      expect(page).to_not have_css '#account_official_position_badge'

      login_as(official_user3)
      visit account_path

      expect(page).to_not have_css '#account_official_position_badge'
    end

  end

  scenario "Errors on edit" do
    visit account_path

    fill_in 'account_username', with: ''
    click_button 'Save changes'

    expect(page).to have_content error_message
  end

  scenario 'Errors editing credentials' do
    visit root_path

    click_link 'My account'

    expect(current_path).to eq(account_path)

    expect(page).to have_link('Change my credentials')
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

    expect(page).to have_content "Invalid login or password"
  end
end
