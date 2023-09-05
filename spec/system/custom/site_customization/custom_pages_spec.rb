require "rails_helper"

describe "Custom Pages" do
  context "New custom page" do
    context "Published" do
      scenario "Show widget cards for that page" do
        custom_page = create(:site_customization_page, :published)
        create(:widget_card, cardable: custom_page, title: "Card Highlights")

        visit custom_page.url

        expect(page).to have_content "Card Highlights"
      end
    end
  end
end
