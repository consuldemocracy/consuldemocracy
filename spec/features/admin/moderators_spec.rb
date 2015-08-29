require 'rails_helper'

feature 'Admin moderators' do
  background do
    @user = create(:user, username: 'Jose Luis Balbin')
    @moderator = create(:moderator)
    @admin = create(:administrator)
    login_as(@admin.user)
  end

  scenario 'Index' do
    visit admin_moderators_path
    expect(page).to have_content @moderator.name
    expect(page).to have_content @moderator.email
    expect(page).to_not have_content @user.name
  end

  scenario 'Create Moderator', :js do
    visit admin_moderators_path
    fill_in 'email', with: @user.email
    click_button 'Search'

    expect(page).to have_content @user.name
    click_link 'Add'
    within("#moderators") do
      expect(page).to have_content @user.name
    end
  end

  scenario 'Delete Moderator' do
    visit admin_moderators_path
    click_link 'Delete'

    within("#moderators") do
      expect(page).to_not have_content @moderator.name
    end
  end
end

