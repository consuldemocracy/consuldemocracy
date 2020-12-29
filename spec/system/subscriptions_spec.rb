require "rails_helper"

describe "Subscriptions" do
  let(:user) { create(:user, subscriptions_token: SecureRandom.base58(32)) }

  context "Update" do
    scenario "Allow updating the status notification" do
      user.update!(email_on_comment: false,
                   email_on_comment_reply: true,
                   newsletter: true,
                   email_digest: false,
                   email_on_direct_message: true)
      visit edit_subscriptions_path(token: user.subscriptions_token)

      check "Notify me by email when someone comments on my proposals or debates"
      uncheck "Notify me by email when someone replies to my comments"
      uncheck "Receive by email website relevant information"
      check "Receive a summary of proposal notifications"
      uncheck "Receive emails about direct messages"
      click_button "Save changes"

      expect(page).to have_content "Changes saved"
      expect(page).to have_field "Notify me by email when someone comments on my contents", checked: true
      expect(page).to have_field "Notify me by email when someone replies to my comments", checked: false
      expect(page).to have_field "Receive by email website relevant information", checked: false
      expect(page).to have_field "Receive a summary of proposal notifications", checked: true
      expect(page).to have_field "Receive emails about direct messages", checked: false
    end
  end
end
