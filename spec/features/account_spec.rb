require 'rails_helper'

feature 'Account' do

  background do
    @user = create(:user, first_name: "Manuela", last_name: "Colau")
    login_as(@user)
  end

  scenario 'Show' do
    visit root_path

    click_link "My account"

    expect(current_path).to eq(account_path)

    expect(page).to have_selector("input[value='Manuela']")
    expect(page).to have_selector("input[value='Colau']")
    expect(page).to have_selector(avatar('Manuela Colau'), count: 1)
  end

  scenario 'Edit' do
    visit account_path

    fill_in 'account_first_name', with: 'Larry'
    fill_in 'account_last_name', with: 'Bird'
    check 'account_email_on_debate_comment'
    check 'account_email_on_comment_reply'
    click_button 'Save changes'

    expect(page).to have_content "Saved"

    visit account_path

    expect(page).to have_selector("input[value='Larry']")
    expect(page).to have_selector("input[value='Bird']")
    expect(page).to have_selector("input[id='account_email_on_debate_comment'][value='1']")
    expect(page).to have_selector("input[id='account_email_on_comment_reply'][value='1']")
  end

  scenario "Errors on edit" do
    visit account_path

    fill_in 'account_first_name', with: ''
    click_button 'Save changes'

    expect(page).to have_content error_message
  end

  scenario 'Errors editing credentials' do
    visit account_path

    click_link 'Change my credentials'
    click_button 'Update'

    expect(page).to have_content error_message
  end
end
