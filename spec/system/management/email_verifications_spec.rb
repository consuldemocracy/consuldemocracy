require "rails_helper"

describe "EmailVerifications" do
  scenario "Verifying a level 1 user via email" do
    user = create(:user)

    in_browser(:user) do
      login_as user
      visit root_path

      expect(page).to have_content "Debates"
    end

    in_browser(:manager) do
      login_as_manager
      visit management_document_verifications_path
      fill_in "document_verification_document_number", with: "12345678Z"
      click_button "Check document"

      expect(page).to have_content "Please introduce the email used on the account"

      fill_in "email_verification_email", with: user.email
      click_button "Send verification email"

      expect(page).to have_content "In order to completely verify this user, " \
                                   "it is necessary that the user clicks on a link"
    end

    sent_token = /.*email_verification_token=(.*)".*/.match(ActionMailer::Base.deliveries.last.body.to_s)[1]

    in_browser(:user) do
      visit email_path(email_verification_token: sent_token)

      expect(page).to have_content "You are a verified user"
      expect(page).to have_content "Account verified"
      expect(page).not_to have_link "Verify my account"
    end

    in_browser(:manager) do
      visit management_document_verifications_path
      fill_in "document_verification_document_number", with: "12345678Z"
      click_button "Check document"

      expect(page).to have_content "This user account is already verified"
    end
  end
end
