require "rails_helper"

feature "EmailVerifications" do

  scenario "Verifying a level 1 user via email" do
    login_as_manager

    user = create(:user)

    visit management_document_verifications_path
    fill_in "document_verification_document_number", with: "12345678Z"
    click_button "Check document"

    expect(page).to have_content "Please introduce the email used on the account"

    fill_in "email_verification_email", with: user.email
    click_button "Send verification email"

    expect(page).to have_content("In order to completely verify this user, it is necessary that the user clicks on a link")

    user.reload

    login_as(user)

    sent_token = /.*email_verification_token=(.*)".*/.match(ActionMailer::Base.deliveries.last.body.to_s)[1]
    visit email_path(email_verification_token: sent_token)

    expect(page).to have_content "You are a verified user"

    expect(page).not_to have_link "Verify my account"
    expect(page).to have_content "Account verified"

    expect(user.reload.document_number).to eq("12345678Z")
    expect(user).to be_level_three_verified
  end

end