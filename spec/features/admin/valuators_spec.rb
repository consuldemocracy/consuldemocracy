require 'rails_helper'

feature 'Admin valuators' do
  background do
    @admin = create(:administrator)
    @user  = create(:user, username: 'Jose Luis Balbin')
    @valuator = create(:valuator)
    login_as(@admin.user)
    visit admin_valuators_path
  end

  scenario 'Index' do
    expect(page).to have_content @valuator.name
    expect(page).to have_content @valuator.email
    expect(page).to_not have_content @user.name
  end

  scenario 'Create Valuator', :js do
    fill_in 'email', with: @user.email
    click_button 'Search'

    expect(page).to have_content @user.name
    click_link 'Add'
    within("#valuators") do
      expect(page).to have_content @user.name
    end
  end

end

