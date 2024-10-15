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

  scenario "redirects root path requests to the admin tenants path" do
    visit root_path

    expect(page).to have_content "CONSUL ADMINISTRATION", normalize_ws: true
    expect(page).to have_content "Multitenancy"
    expect(page).not_to have_content "Most active proposals"
  end

  scenario "does not redirect other tenants when visiting the root path", :seed_tenants do
    create(:tenant, schema: "mars")

    with_subdomain("mars") do
      visit root_path

      expect(page).to have_content "Most active proposals"
      expect(page).not_to have_content "Multitenancy"
      expect(page).not_to have_content "CONSUL ADMINISTRATION", normalize_ws: true
    end
  end

  scenario "redirects to account path when regular user try access to admin section" do
    logout
    login_as(create(:user))

    visit admin_root_path

    expect(page).to have_current_path account_path
    expect(page).to have_content "You do not have permission to access this page."
  end
end
