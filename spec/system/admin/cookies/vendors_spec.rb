require "rails_helper"

describe "Admin cookies vendors", :admin do
  describe "Index" do
    scenario "Shows existing cookies and links to actions" do
      create(:cookies_vendor, name: "Third party", cookie: "third_party")
      visit admin_settings_path(anchor: "tab-cookies-consent")

      expect(page).to have_content "Third party"
      expect(page).to have_content "third_party"
      expect(page).to have_link "Edit"
      expect(page).to have_button "Delete"
      expect(page).to have_link "Create cookie vendor"
    end
  end

  describe "Create" do
    scenario "Shows a notice and the new cookie after creation" do
      visit admin_settings_path(anchor: "tab-cookies-consent")

      click_link "Create cookie vendor"
      fill_in "Vendor name", with: "Vendor name"
      fill_in "Cookie name", with: "vendor_cookie"
      fill_in "Description", with: "Cookie details"
      click_button "Create cookie vendor"

      expect(page).to have_content "Cookie vendor created successfully"
      expect(page).to have_content "Vendor name"
      expect(page).to have_content "vendor_cookie"
    end
  end

  describe "Update" do
    scenario "Shows a notice and the cookie changes after update" do
      create(:cookies_vendor, name: "Third party", cookie: "third_party")
      visit admin_settings_path(anchor: "tab-cookies-consent")

      click_link "Edit"
      fill_in "Vendor name", with: "Cool Company Name"
      click_button "Update cookie vendor"

      expect(page).to have_content "Cookie vendor updated successfully"
      expect(page).to have_content "Cool Company Name"
    end
  end

  describe "Destroy" do
    scenario "Shows a notice and removes cookie" do
      create(:cookies_vendor, name: "Analitics cookie", cookie: "analitics_cookie")
      visit admin_settings_path(anchor: "tab-cookies-consent")

      expect(page).to have_content "Analitics cookie"
      expect(page).to have_content "analitics_cookie"

      accept_confirm { click_button "Delete Analitics cookie" }

      expect(page).to have_content "Cookie vendor deleted successfully"
      expect(page).not_to have_content "Analitics cookie"
      expect(page).not_to have_content "analitics_cookie"
    end
  end
end
