require "rails_helper"

describe "Multitenancy management mode", :admin do
  before do
    allow(Rails.application.config).to receive(:multitenancy_management_mode).and_return(true)
    Setting["org_name"] = "CONSUL"
  end

  scenario "renders expected content for multitenancy manage mode in admin section" do
    visit admin_root_path

    within ".top-links" do
      expect(page).not_to have_content "Go back to CONSUL"
    end

    within ".top-bar" do
      expect(page).to have_css "li", count: 2
      expect(page).to have_content "My account"
      expect(page).to have_content "Sign out"
    end

    within "#admin_menu" do
      expect(page).to have_content "Multitenancy"
      expect(page).to have_content "Administrators"
      expect(page).to have_css "li", count: 2
    end
  end
end
