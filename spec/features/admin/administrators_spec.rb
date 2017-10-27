require 'rails_helper'

feature 'Admin administrators' do
  background do
    @admin = create(:administrator)
    @user  = create(:user, username: 'Jose Luis Balbin')
    @administrator = create(:administrator)
    login_as(@admin.user)
    visit admin_administrators_path
  end

  scenario 'Index' do
    expect(page).to have_content @administrator.name
    expect(page).to have_content @administrator.email
    expect(page).to_not have_content @user.name
  end

  scenario 'Create Administrator', :js do
    fill_in 'name_or_email', with: @user.email
    click_button 'Search'

    expect(page).to have_content @user.name
    click_link 'Add'
    within("#administrators") do
      expect(page).to have_content @user.name
    end
  end

  scenario 'Delete Administrator' do
    find(:xpath, "//tr[contains(.,'#{@administrator.name}')]/td/a", text: 'Delete').click

    within("#administrators") do
      expect(page).to_not have_content @administrator.name
    end
  end

  scenario 'Delete Administrator when its the current user' do
    find(:xpath, "//tr[contains(.,'#{@admin.name}')]/td/a", text: 'Delete').click

    within("#error") do
      expect(page).to have_content I18n.t("admin.administrators.administrator.restricted_removal")
    end
  end

  context 'Search' do

    background do
      user  = create(:user, username: 'Bernard Sumner', email: 'bernard@sumner.com')
      user2 = create(:user, username: 'Tony Soprano', email: 'tony@soprano.com')
      @administrator1 = create(:administrator, user: user)
      @administrator2 = create(:administrator, user: user2)
      visit admin_administrators_path
    end

    scenario 'returns no results if search term is empty' do
      expect(page).to have_content(@administrator1.name)
      expect(page).to have_content(@administrator2.name)

      fill_in 'name_or_email', with: ' '
      click_button 'Search'

      expect(page).to have_content('Administrators: User search')
      expect(page).to have_content('No results found')
      expect(page).to_not have_content(@administrator1.name)
      expect(page).to_not have_content(@administrator2.name)
    end

    scenario 'search by name' do
      expect(page).to have_content(@administrator1.name)
      expect(page).to have_content(@administrator2.name)

      fill_in 'name_or_email', with: 'Sumn'
      click_button 'Search'

      expect(page).to have_content('Administrators: User search')
      expect(page).to have_content(@administrator1.name)
      expect(page).to_not have_content(@administrator2.name)
    end

    scenario 'search by email' do
      expect(page).to have_content(@administrator1.email)
      expect(page).to have_content(@administrator2.email)

      fill_in 'name_or_email', with: @administrator2.email
      click_button 'Search'

      expect(page).to have_content('Administrators: User search')
      expect(page).to have_content(@administrator2.email)
      expect(page).to_not have_content(@administrator1.email)
    end
  end

end
