require "rails_helper"

describe "Cards", :admin do
  context "Header Card" do
    scenario "Create" do
      visit admin_homepage_path
      click_link "Create header"

      fill_in "Label (optional)", with: "Header label"
      fill_in "Title", with: "Header text"
      fill_in_ckeditor "Description", with: "Header description"
      fill_in "Link text", with: "Link text"
      fill_in "widget_card_link_url", with: "consul.dev"
      click_button "Create header"

      expect(page).to have_content "Card created successfully!"

      within("#header") do
        expect(page).to have_css(".homepage-card", count: 1)
        expect(page).to have_content "Header label"
        expect(page).to have_content "Header text"
        expect(page).to have_content "Header description"
        expect(page).to have_content "Link text"
        expect(page).to have_content "consul.dev"
      end

      within("#cards") do
        expect(page).to have_css(".homepage-card", count: 0)
      end
    end

    context "Page card" do
      let!(:custom_page) { create(:site_customization_page, :published) }

      scenario "Show image if it is present" do
        card_1 = create(:widget_card, cardable: custom_page, title: "Card one")
        card_2 = create(:widget_card, cardable: custom_page, title: "Card two")

        card_1.update!(image: create(:image, imageable: card_1, attachment: fixture_file_upload("clippy.jpg")))
        card_2.update!(image: nil)

        visit custom_page.url

        within(".card", text: "Card one") { expect(page).to have_css "img" }
        within(".card", text: "Card two") { expect(page).not_to have_css "img" }
      end
    end
  end
end
