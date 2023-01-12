require "rails_helper"

describe Layout::AdminHeaderComponent do
  let(:user) { create(:user) }
  before { Setting["org_name"] = "CONSUL" }

  around do |example|
    with_request_url("/") { example.run }
  end

  context "management section", controller: Management::BaseController do
    it "shows the menu button and menu for administrators" do
      create(:administrator, user: user)

      render_inline Layout::AdminHeaderComponent.new(user)

      expect(page).to have_link "Go back to CONSUL"
      expect(page).to have_link "You don't have new notifications"
      expect(page).to have_link "My content"
      expect(page).to have_link "My account"
      expect(page).to have_link "Sign out"
      expect(page).to have_css "[data-toggle]"
    end

    it "does not show the menu button and menu for managers" do
      create(:manager, user: user)

      render_inline Layout::AdminHeaderComponent.new(user)

      expect(page).to have_link "Go back to CONSUL"
      expect(page).not_to have_content "You don't have new notifications"
      expect(page).not_to have_content "My content"
      expect(page).not_to have_content "My account"
      expect(page).not_to have_content "Sign out"
      expect(page).not_to have_css "[data-toggle]"
    end
  end
end
