require 'rails_helper'

feature 'Admin moderators' do
  background do
    @admin = create(:administrator)
    @user  = create(:user, username: 'Jose Luis Balbin')
    @moderator = create(:moderator)
    login_as(@admin.user)
    visit admin_moderators_path
  end

  scenario 'Index' do
    expect(page).to have_content @moderator.name
    expect(page).to have_content @moderator.email
    expect(page).to_not have_content @user.name
  end

  scenario 'Create Moderator', :js do
    fill_in 'email', with: @user.email
    click_button 'Search'

    expect(page).to have_content @user.name
    click_link 'Add'
    within("#moderators") do
      expect(page).to have_content @user.name
    end
  end

  scenario 'Delete Moderator' do
    click_link 'Delete'

    within("#moderators") do
      expect(page).to_not have_content @moderator.name
    end
  end
end

