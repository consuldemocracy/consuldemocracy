require 'rails_helper'

feature 'Admin poll officers' do
  background do
    @admin = create(:administrator)
    @user  = create(:user, username: 'Pedro Jose Garcia')
    @officer = create(:poll_officer)
    login_as(@admin.user)
    visit admin_poll_officers_path
  end

  scenario 'Index' do
    expect(page).to have_content @officer.name
    expect(page).to have_content @officer.email
    expect(page).to_not have_content @user.name
  end

  scenario 'Create poll officer', :js do
    fill_in 'email', with: @user.email
    click_button 'Search'

    expect(page).to have_content @user.name
    click_link 'Add'
    within("#officers") do
      expect(page).to have_content @user.name
    end
  end

  scenario 'Delete poll officer' do
    click_link 'Delete'

    within("#officers") do
      expect(page).to_not have_content @officer.name
    end
  end
end