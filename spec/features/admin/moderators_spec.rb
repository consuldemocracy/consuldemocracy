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
    fill_in 'name_or_email', with: @user.email
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

  context 'Search' do

    background do
      user  = create(:user, username: 'Elizabeth Bathory', email: 'elizabeth@bathory.com')
      user2 = create(:user, username: 'Ada Lovelace', email: 'ada@lovelace.com')
      @moderator1 = create(:moderator, user: user)
      @moderator2 = create(:moderator, user: user2)
      visit admin_moderators_path
    end

    scenario 'returns no results if search term is empty' do
      expect(page).to have_content(@moderator1.name)
      expect(page).to have_content(@moderator2.name)

      fill_in 'name_or_email', with: ' '
      click_button 'Search'

      expect(page).to have_content('Moderators: User search')
      expect(page).to have_content('No results found')
      expect(page).to_not have_content(@moderator1.name)
      expect(page).to_not have_content(@moderator2.name)
    end

    scenario 'search by name' do
      expect(page).to have_content(@moderator1.name)
      expect(page).to have_content(@moderator2.name)

      fill_in 'name_or_email', with: 'Eliz'
      click_button 'Search'

      expect(page).to have_content('Moderators: User search')
      expect(page).to have_content(@moderator1.name)
      expect(page).to_not have_content(@moderator2.name)
    end

    scenario 'search by email' do
      expect(page).to have_content(@moderator1.email)
      expect(page).to have_content(@moderator2.email)

      fill_in 'name_or_email', with: @moderator2.email
      click_button 'Search'

      expect(page).to have_content('Moderators: User search')
      expect(page).to have_content(@moderator2.email)
      expect(page).to_not have_content(@moderator1.email)
    end
  end

end
