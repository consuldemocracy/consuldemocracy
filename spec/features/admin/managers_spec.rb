require 'rails_helper'

feature 'Admin managers' do
  background do
    @admin = create(:administrator)
    @user  = create(:user)
    @manager = create(:manager)
    login_as(@admin.user)
    visit admin_managers_path
  end

  scenario 'Index' do
    expect(page).to have_content @manager.name
    expect(page).to have_content @manager.email
    expect(page).to_not have_content @user.name
  end

  scenario 'Create Manager', :js do
    fill_in 'email', with: @user.email
    click_button 'Search'

    expect(page).to have_content @user.name
    click_link 'Add'
    within("#managers") do
      expect(page).to have_content @user.name
    end
  end

  scenario 'Delete Manager' do
    click_link 'Delete'

    within("#managers") do
      expect(page).to_not have_content @manager.name
    end
  end

end