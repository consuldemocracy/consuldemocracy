require 'rails_helper'

feature 'Stats' do

  scenario 'Level 2 user', :focus do
    admin = create(:administrator)
    user = create(:user)
    login_as(user)

    visit account_path
    click_link 'Verify my account'
    verify_residence
    confirm_phone

    login_as(admin.user)
    visit stats_path

    expect(page).to have_content "Level 2 User (1)"
  end

end