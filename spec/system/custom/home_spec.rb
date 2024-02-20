require "rails_helper"

describe "Home" do
  scenario "if there are cards, the 'featured' title will render" do
    create(:widget_card,
      title: "Card text",
      description: "Card description",
      link_text: "Link text",
      link_url: "consul.dev"
    )

    visit root_path

    within("#welcome_cards") do
      expect(page).to have_css(".title", text: "Featured")
    end
  end

  scenario "if there are no cards, the 'featured' title will not render" do
    visit root_path

    within("#welcome_cards") do
      expect(page).not_to have_css(".title", text: "Featured")
    end
  end

  scenario "Cards are ordered by creation date" do
    create(:widget_card, title: "Card one", link_text: "Link one", link_url: "consul.dev")
    create(:widget_card, title: "Card two", link_text: "Link two", link_url: "consul.dev")
    create(:widget_card, title: "Card three", link_text: "Link three", link_url: "consul.dev")

    visit root_path

    within("#welcome_cards") do
      expect("Card three").to appear_before("Card two")
      expect("Card two").to appear_before("Card one")
    end
  end

  scenario "Favicon custom" do
    visit root_path

    expect(page).to have_css("link[rel=\"shortcut icon\"]", visible: :hidden)
    expect(page).to have_xpath("//link[contains(@href, \"favicon-\")]", visible: :hidden)

    create(:site_customization_image, name: "favicon", image: fixture_file_upload("favicon_custom.ico"))

    visit root_path

    expect(page).to have_css("link[rel=\"shortcut icon\"]", visible: :hidden)
    expect(page).not_to have_xpath("//link[contains(@href, \"favicon-\")]", visible: :hidden)
    expect(page).to have_xpath("//link[contains(@href, \"favicon_custom\")]", visible: :hidden)
  end
end
