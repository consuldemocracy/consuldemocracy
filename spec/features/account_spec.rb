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

  scenario 'Edit' do
    login_as(@user)
    visit account_path

    fill_in 'account_first_name', with: 'Larry'
    fill_in 'account_last_name', with: 'Bird'
    click_button 'Save changes'

    expect(page).to have_content "Saved"

    visit account_path

    expect(page).to have_selector("input[value='Larry']")
    expect(page).to have_selector("input[value='Bird']")
  end
end