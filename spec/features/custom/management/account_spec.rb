require 'rails_helper'

feature 'Account' do

  background do
    Setting["org_name"] = 'MASDEMOCRACIAEUROPA'
    login_as_manager
  end

  scenario "Display custom menu when org_name is MASDEMOCRACIAEUROPA" do
    user = create(:user)
    login_managed_user(user)

    visit management_root_path

    expect(page).to have_content "Edit user account"
    expect(page).to have_content "Print proposals"
    expect(page).to have_content "Send invitations"
    expect(page).not_to have_content "Create proposal"
    expect(page).not_to have_content "Users"
    expect(page).not_to have_content "Support proposals"
    expect(page).not_to have_content "Create spending proposals"
    expect(page).not_to have_content "Support spending proposals"
    expect(page).not_to have_content "Print spending proposals"

  end

end
