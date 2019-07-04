require "rails_helper"

feature "Admin custom pages" do

  background do
    admin = create(:administrator)
    login_as(admin.user)
  end

  it_behaves_like "translatable",
                  "site_customization_page",
                  "edit_admin_site_customization_page_path",
                  %w[title subtitle],
                  { "content" => :ckeditor }

  scenario "Index" do
    custom_page = create(:site_customization_page)
    visit admin_site_customization_pages_path

    expect(page).to have_content(custom_page.title)
    expect(page).to have_content(custom_page.slug)
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

      click_link "An example custom page"

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

      within(".ckeditor") do
        expect(page).to have_css(".cke_toolbar .cke_button__image_icon")
      end
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
