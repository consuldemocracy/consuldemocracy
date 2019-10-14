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
    fill_in 'email', with: @user.email
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
end

