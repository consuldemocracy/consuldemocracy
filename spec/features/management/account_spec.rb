require 'rails_helper'

describe 'Account' do

  before do
    login_as_manager
  end

  it "Should not allow unverified users to create spending proposals" do
    user = create(:user)
    login_managed_user(user)

    click_link "Edit user account"

    expect(page).to have_content "No verified user logged in yet"
  end

  it 'Delete a user account', :js do
    user = create(:user, :level_two)
    login_managed_user(user)

    visit management_account_path

    click_link "Delete user"
    click_link "Delete account"

    expect(page).to have_content "User account deleted."

    expect(user.reload.erase_reason).to eq "Deleted by manager: manager_user_#{Manager.last.user_id}"
  end

end