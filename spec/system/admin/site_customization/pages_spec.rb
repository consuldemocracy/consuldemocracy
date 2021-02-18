require "rails_helper"

describe "Admin custom pages", :admin do
  context "Index" do
    scenario "lists all created custom pages" do
      custom_page = create(:site_customization_page)
      visit admin_site_customization_pages_path

      expect(page).to have_content(custom_page.title)
      expect(page).to have_content(custom_page.slug)
    end

    scenario "should contain all default custom pages published populated by db:seeds" do
      slugs = %w[accessibility conditions faq privacy welcome_not_verified
                 welcome_level_two_verified welcome_level_three_verified]

      visit admin_site_customization_pages_path

      expect(SiteCustomization::Page.count).to be 7
      slugs.each do |slug|
        expect(SiteCustomization::Page.find_by(slug: slug).status).to eq "published"
      end

      expect(all("[id^='site_customization_page_']").count).to be 7
      slugs.each do |slug|
        expect(page).to have_content slug
      end
    end
  end

  context "Create" do
    scenario "Valid custom page" do
      visit admin_root_path

      within("#side_menu") do
        click_link "Custom pages"
      end

      expect(page).not_to have_content "An example custom page"
      expect(page).not_to have_content "example-page"

      click_link "Create new page"

      fill_in "Title", with: "An example custom page"
      fill_in "Subtitle", with: "Page subtitle"
      fill_in "site_customization_page_slug", with: "example-page"
      fill_in "Content", with: "This page is about..."

      click_button "Create Custom page"

      expect(page).to have_content "An example custom page"
      expect(page).to have_content "example-page"
    end
  end

  context "Update" do
    let!(:custom_page) do
      create(:site_customization_page, title: "An example custom page", slug: "custom-example-page")
    end

    scenario "Valid custom page" do
      visit admin_root_path

      within("#side_menu") do
        click_link "Custom pages"
      end

      within("tr", text: "An example custom page") { click_link "Edit" }

      expect(page).to have_selector("h2", text: "An example custom page")
      expect(page).to have_selector("input[value='custom-example-page']")

      fill_in "Title", with: "Another example custom page"
      fill_in "site_customization_page_slug", with: "another-custom-example-page"
      click_button "Update Custom page"

      expect(page).to have_content "Page updated successfully"
      expect(page).to have_content "Another example custom page"
      expect(page).to have_content "another-custom-example-page"
    end

    scenario "Allows images in CKEditor", :js do
      visit edit_admin_site_customization_page_path(custom_page)
      fill_in_ckeditor "Content", with: "Will add an image"

      expect(page).to have_css(".cke_toolbar .cke_button__image_icon")
    end
  end

  scenario "Delete" do
    custom_page = create(:site_customization_page, title: "An example custom page")
    visit edit_admin_site_customization_page_path(custom_page)

    click_link "Delete page"

    expect(page).not_to have_content "An example custom page"
    expect(page).not_to have_content "example-page"
  end
end
