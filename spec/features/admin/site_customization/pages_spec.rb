require 'rails_helper'

feature "Admin custom pages" do

  background do
    admin = create(:administrator)
    login_as(admin.user)
  end

  scenario "Index" do
    custom_page = create(:site_customization_page)
    visit admin_site_customization_pages_path

    expect(page).to have_content(custom_page.title)
  end

  context "Create" do
    scenario "Valid custom page" do
      visit admin_root_path

      within("#side_menu") do
        click_link "Custom pages"
      end

      expect(page).not_to have_content "An example custom page"

      click_link "Create new page"

      fill_in "site_customization_page_title", with: "An example custom page"
      fill_in "site_customization_page_subtitle", with: "Page subtitle"
      fill_in "site_customization_page_slug", with: "example-page"
      fill_in "site_customization_page_content", with: "This page is about..."
      select 'English', from:"site_customization_page_locale"

      click_button "Create Custom page"

      expect(page).to have_content "An example custom page"
    end
  end

  context "Update" do
    scenario "Valid custom page" do
      create(:site_customization_page, title: "An example custom page")
      visit admin_root_path

      within("#side_menu") do
        click_link "Custom pages"
      end

      click_link "An example custom page"

      expect(page).to have_selector("h2", text: "An example custom page")

      fill_in "site_customization_page_title", with: "Another example custom page"
      click_button "Update Custom page"

      expect(page).to have_content "Page updated successfully"
      expect(page).to have_content "Another example custom page"
    end
  end

  scenario "Delete" do
    custom_page = create(:site_customization_page, title: "An example custom page")
    visit edit_admin_site_customization_page_path(custom_page)

    click_link "Delete page"

    expect(page).not_to have_content("An example custom page")
  end
end
