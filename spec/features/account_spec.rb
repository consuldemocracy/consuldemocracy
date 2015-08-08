require 'rails_helper'

feature 'Account' do

  background do
    @user = create(:user, first_name: "Manuela", last_name:"Colau")
  end

  scenario 'Show' do
    login_as(@user)
    visit root_path
    click_link "My account"

    expect(page).to have_selector("input[value='Manuela']")
    expect(page).to have_selector("input[value='Colau']")
  end

  scenario "Failed Edit" do
    login_as(@user)
    visit account_path

    fill_in 'account_first_name', with: ''
    fill_in 'account_last_name', with: ''
    fill_in 'account_nickname', with: ''
    click_button 'Save changes'

    expect(page).to have_content "2 errors prohibited this debate from being saved"
    expect(page).to have_content "First name can't be blank"
    expect(page).to have_content "First name can't be blank"
  end

  scenario 'Edit' do
    login_as(@user)
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
end