require "rails_helper"

describe "Users" do
  scenario "Create a level 3 user with email from scratch" do
    login_as_manager
    visit management_document_verifications_path
    fill_in "document_verification_document_number", with: "12345678Z"
    click_button "Check document"

    expect(page).to have_content "Please introduce the email used on the account"

    click_link "Create a new account"

    fill_in "user_username", with: "pepe"
    fill_in "user_email", with: "pepe@gmail.com"
    fill_in "Date of birth", with: Date.new(1980, 12, 31)

    click_button "Create user"

    expect(page).to have_content "We have sent an email"
    expect(page).not_to have_content "Autogenerated password is"

    user = User.find_by(email: "pepe@gmail.com")

    expect(user).to be_level_three_verified
    expect(user).to be_residence_verified
    expect(user).not_to be_confirmed
    expect(user.date_of_birth).to have_content Date.new(1980, 12, 31)

    sent_token = /.*confirmation_token=(.*)".*/.match(ActionMailer::Base.deliveries.last.body.to_s)[1]
    visit user_confirmation_path(confirmation_token: sent_token)

    expect(page).to have_content "Confirming the account with email"

    fill_in "user_password", with: "12345678"
    fill_in "user_password_confirmation", with: "12345678"

    click_button "Confirm"

    expect(user.reload).to be_confirmed

    expect(page).to have_content "Your account has been confirmed."
  end

  scenario "Create a level 3 user without email from scratch" do
    login_as_manager
    visit management_document_verifications_path
    fill_in "document_verification_document_number", with: "12345678Z"
    click_button "Check document"

    expect(page).to have_content "Please introduce the email used on the account"

    click_link "Create a new account"

    fill_in "user_username", with: "Kelly Sue"
    fill_in "user_email", with: ""
    fill_in "Date of birth", with: Date.new(1980, 12, 31)

    click_button "Create user"

    expect(page).not_to have_content "We have sent an email"
    expect(page).to have_content "Autogenerated password is"

    user = User.find_by(username: "Kelly Sue")

    expect(user).to be_level_three_verified
    expect(user).to be_residence_verified
    expect(user).to be_confirmed
    expect(user.date_of_birth).to have_content Date.new(1980, 12, 31)
  end

  scenario "Delete a level 2 user account from document verification page" do
    level_2_user = create(:user, :level_two, document_number: "12345678Z")
    manager = create(:manager)
    administrator = create(:administrator)

    login_as_manager(manager)
    visit management_document_verifications_path
    fill_in "document_verification_document_number", with: "12345678Z"
    click_button "Check document"

    expect(page).to have_content "This user can participate in the website with the following permissions"
    expect(page).not_to have_content "This user account is already verified."

    click_link "Delete user"
    accept_confirm { click_button "Delete account" }

    expect(page).to have_content "User account deleted."

    fill_in "document_verification_document_number", with: "12345678Z"
    click_button "Check document"

    expect(page).to have_content "no user account associated to it"

    logout
    login_as(administrator.user)

    visit admin_users_path(filter: "erased")

    within "tr", text: level_2_user.id do
      expect(page).to have_content "Deleted by manager: manager_user_#{manager.user_id}"
    end
  end
end
