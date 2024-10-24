require "rails_helper"

describe Subscriptions::EditComponent do
  let(:user) { create(:user, subscriptions_token: SecureRandom.base58(32)) }
  let(:component) { Subscriptions::EditComponent.new(user) }

  it "renders checkboxes to change the subscriptions preferences" do
    render_inline component

    expect(page).to have_content "Notifications"
    expect(page).to have_field "Notify me by email when someone comments on my contents", type: :checkbox
    expect(page).to have_field "Notify me by email when someone replies to my comments", type: :checkbox
    expect(page).to have_field "Receive relevant information by email", type: :checkbox
    expect(page).to have_field "Receive a summary of proposal notifications", type: :checkbox
    expect(page).to have_field "Receive emails about direct messages", type: :checkbox
    expect(page).to have_button "Save changes"
  end
end
