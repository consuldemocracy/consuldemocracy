require "rails_helper"

feature "Account" do

  background do
    login_as_manager
  end

  scenario "Should not allow unverified users to edit their account" do
    user = create(:user)
    login_managed_user(user)

    visit management_root_path

    click_link "Reset password via email"

    expect(page).to have_content "No verified user logged in yet"
  end

  scenario "Delete a user account", :js do
    user = create(:user, :level_two)
    login_managed_user(user)

    visit management_account_path

    click_link "Delete user"
    accept_confirm { click_link "Delete account" }

    expect(page).to have_content "User account deleted."

    expect(user.reload.erase_reason).to eq "Deleted by manager: manager_user_#{Manager.last.user_id}"
  end

  scenario "Send reset password email to currently managed user session" do
    user = create(:user, :level_three)
    login_managed_user(user)
    visit management_root_path

    click_link "Reset password via email"

    click_link "Send reset password email"

    expect(page).to have_content "Email correctly sent."

    email = ActionMailer::Base.deliveries.last

    expect(email).to have_text "Change your password"
  end

  scenario "Manager changes the password by hand (writen by them)" do
    user = create(:user, :level_three)
    login_managed_user(user)
    visit management_root_path

    click_link "Reset password manually"

    find(:css, "input[id$='user_password']").set("new_password")

    click_button "Save password"

    expect(page).to have_content "Password reseted successfully"

    logout

    login_through_form_with_email_and_password(user.email, "new_password")

    expect(page).to have_content "You have been signed in successfully."
  end

  scenario "Manager generates random password", :js do
    user = create(:user, :level_three)
    login_managed_user(user)
    visit management_root_path

    click_link "Reset password manually"
    click_link "Generate random password"

    new_password = find_field("user_password").value

    click_button "Save password"

    expect(page).to have_content "Password reseted successfully"

    logout

    login_through_form_with_email_and_password(user.username, new_password)

    expect(page).to have_content "You have been signed in successfully."
  end

  scenario "The password is printed", :js do
    user = create(:user, :level_three)
    login_managed_user(user)
    visit management_root_path

    click_link "Reset password manually"

    find(:css, "input[id$='user_password']").set("another_new_password")

    click_button "Save password"

    expect(page).to have_content "Password reseted successfully"
    expect(page).to have_css("a[href='javascript:window.print();']", text: "Print password")
    expect(page).to have_css("div.for-print-only", text: "another_new_password", visible: false)
  end

end
