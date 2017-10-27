require 'rails_helper'

feature 'Admin valuators' do
  background do
    @admin    = create(:administrator)
    @user     = create(:user, username: 'Jose Luis Balbin')
    @valuator = create(:valuator)
    login_as(@admin.user)
    visit admin_valuators_path
  end

  scenario 'Index' do
    expect(page).to have_content(@valuator.name)
    expect(page).to have_content(@valuator.email)
    expect(page).to_not have_content(@user.name)
  end

  scenario 'Create Valuator', :js do
    fill_in 'name_or_email', with: @user.email
    click_button 'Search'

    expect(page).to have_content(@user.name)
    fill_in 'valuator_description', with: 'environmental expert'
    click_button 'Add to valuators'

    within('#valuators') do
      expect(page).to have_content(@user.name)
      expect(page).to have_content('environmental expert')
    end
  end

  context 'Search' do

    background do
      user  = create(:user, username: 'David Foster Wallace', email: 'david@wallace.com')
      user2 = create(:user, username: 'Steven Erikson', email: 'steven@erikson.com')
      @valuator1 = create(:valuator, user: user)
      @valuator2 = create(:valuator, user: user2)
      visit admin_valuators_path
    end

    scenario 'returns no results if search term is empty' do
      expect(page).to have_content(@valuator1.name)
      expect(page).to have_content(@valuator2.name)

      fill_in 'name_or_email', with: ' '
      click_button 'Search'

      expect(page).to have_content('Valuators: User search')
      expect(page).to have_content('No results found')
      expect(page).to_not have_content(@valuator1.name)
      expect(page).to_not have_content(@valuator2.name)
    end

    scenario 'search by name' do
      expect(page).to have_content(@valuator1.name)
      expect(page).to have_content(@valuator2.name)

      fill_in 'name_or_email', with: 'Foster'
      click_button 'Search'

      expect(page).to have_content('Valuators: User search')
      expect(page).to have_content(@valuator1.name)
      expect(page).to_not have_content(@valuator2.name)
    end

    scenario 'search by email' do
      expect(page).to have_content(@valuator1.email)
      expect(page).to have_content(@valuator2.email)

      fill_in 'name_or_email', with: @valuator2.email
      click_button 'Search'

      expect(page).to have_content('Valuators: User search')
      expect(page).to have_content(@valuator2.email)
      expect(page).to_not have_content(@valuator1.email)
    end
  end

end
