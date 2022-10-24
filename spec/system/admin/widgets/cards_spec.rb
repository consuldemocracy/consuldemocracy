require "rails_helper"

describe "Cards", :admin do
  scenario "Create" do
    visit admin_homepage_path
    click_link "Create card"

    expect(page).to have_link("Go back", href: admin_homepage_path)

    fill_in "Label (optional)", with: "Card label"
    fill_in "Title", with: "Card text"
    fill_in "Description", with: "Card description"
    fill_in "Link text", with: "Link text"
    fill_in "widget_card_link_url", with: "consul.dev"
    attach_image_to_card
    click_button "Create card"

    expect(page).to have_content "Card created successfully!"
    expect(page).to have_css(".homepage-card", count: 1)

    within "#cards" do
      within all("tbody tr").last do
        expect(page).to have_content "Card label"
        expect(page).to have_content "Card text"
        expect(page).to have_content "Card description"
        expect(page).to have_content "Link text"
        expect(page).to have_content "consul.dev"
        expect(page).to have_link "Show image", title: "clippy.jpg"
      end
    end
  end

  scenario "Create with errors" do
    visit admin_homepage_path
    click_link "Create card"
    click_button "Create card"

    expect(page).to have_text error_message
    expect(page).to have_button "Create card"
  end

  scenario "Index" do
    cards = Array.new(3) { create(:widget_card) }

    visit admin_homepage_path

    expect(page).to have_css(".homepage-card", count: 3)

    cards.each do |card|
      expect(page).to have_content card.title
      expect(page).to have_content card.description
      expect(page).to have_content card.link_text
      expect(page).to have_content card.link_url
      expect(page).to have_link "Show image"
    end
  end

  scenario "Show" do
    card_1 = create(:widget_card, title: "Card homepage large", columns: 8)
    card_2 = create(:widget_card, title: "Card homepage medium", columns: 4)
    card_3 = create(:widget_card, title: "Card homepage small", columns: 2)

    visit root_path

    expect(page).to have_css("#widget_card_#{card_1.id}.medium-8")
    expect(page).to have_css("#widget_card_#{card_2.id}.medium-4")
    expect(page).to have_css("#widget_card_#{card_3.id}.medium-2")
  end

  scenario "Edit" do
    card = create(:widget_card)

    visit admin_homepage_path

    within("#widget_card_#{card.id}") do
      click_link "Edit"
    end

    expect(page).to have_link("Go back", href: admin_homepage_path)

    within(".translatable-fields") do
      fill_in "Label (optional)", with: "Card label updated"
      fill_in "Title", with: "Card text updated"
      fill_in "Description", with: "Card description updated"
      fill_in "Link text", with: "Link text updated"
    end

    fill_in "widget_card_link_url", with: "consul.dev updated"
    click_button "Save card"

    expect(page).to have_content "Card updated successfully"

    expect(page).to have_css(".homepage-card", count: 1)

    within "#cards" do
      within all("tbody tr").last do
        expect(page).to have_content "Card label updated"
        expect(page).to have_content "Card text updated"
        expect(page).to have_content "Card description updated"
        expect(page).to have_content "Link text updated"
        expect(page).to have_content "consul.dev updated"
      end
    end
  end

  scenario "Remove" do
    card = create(:widget_card)

    visit admin_homepage_path

    within("#widget_card_#{card.id}") do
      accept_confirm("Are you sure? This action will delete \"#{card.title}\" and can't be undone.") do
        click_button "Delete"
      end
    end

    expect(page).to have_content "Card removed successfully"
    expect(page).to have_css(".homepage-card", count: 0)
  end

  context "Header Card" do
    scenario "Create" do
      visit admin_homepage_path
      click_link "Create header"

      fill_in "Label (optional)", with: "Header label"
      fill_in "Title", with: "Header text"
      fill_in "Description", with: "Header description"
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

    scenario "Create with errors" do
      visit admin_homepage_path
      click_link "Create header"
      click_button "Create header"

      expect(page).to have_text error_message
      expect(page).to have_button "Create header"
    end

    context "Page card" do
      let!(:custom_page) { create(:site_customization_page, :published) }

      scenario "Create" do
        visit admin_site_customization_pages_path

        within "#site_customization_page_#{custom_page.id}" do
          click_link "Manage cards"
        end

        click_link "Create card"

        expect(page).to have_link("Go back",
          href: admin_site_customization_page_widget_cards_path(custom_page))

        fill_in "Title", with: "Card for a custom page"
        fill_in "Link URL", with: "/any_path"
        click_button "Create card"

        expect(page).to have_current_path admin_site_customization_page_widget_cards_path(custom_page)
        expect(page).to have_content "Card for a custom page"
      end

      scenario "Show" do
        card_1 = create(:widget_card, cardable: custom_page, title: "Card large", columns: 8)
        card_2 = create(:widget_card, cardable: custom_page, title: "Card medium", columns: 4)
        card_3 = create(:widget_card, cardable: custom_page, title: "Card small", columns: 2)

        visit custom_page.url

        expect(page).to have_css(".card", count: 3)

        expect(page).to have_css("#widget_card_#{card_1.id}.medium-8")
        expect(page).to have_css("#widget_card_#{card_2.id}.medium-4")
        expect(page).to have_css("#widget_card_#{card_3.id}.medium-2")
      end

      scenario "Show label only if it is present" do
        card_1 = create(:widget_card, cardable: custom_page, title: "Card one", label: "My label")
        card_2 = create(:widget_card, cardable: custom_page, title: "Card two")

        visit custom_page.url

        within("#widget_card_#{card_1.id}") do
          expect(page).to have_selector("span", text: "MY LABEL")
        end

        within("#widget_card_#{card_2.id}") do
          expect(page).not_to have_selector("span")
        end
      end

      scenario "Show image if it is present" do
        card_1 = create(:widget_card, cardable: custom_page, title: "Card one")
        card_2 = create(:widget_card, cardable: custom_page, title: "Card two")

        card_1.update!(image: create(:image, imageable: card_1, attachment: fixture_file_upload("clippy.jpg")))
        card_2.update!(image: nil)

        visit custom_page.url

        within(".card", text: "CARD ONE") { expect(page).to have_css "img" }
        within(".card", text: "CARD TWO") { expect(page).not_to have_css "img" }
      end

      scenario "Edit" do
        create(:widget_card, cardable: custom_page, title: "Original title")

        visit admin_site_customization_page_widget_cards_path(custom_page)

        expect(page).to have_content("Original title")

        click_link "Edit"

        expect(page).to have_link("Go back",
          href: admin_site_customization_page_widget_cards_path(custom_page))

        within(".translatable-fields") do
          fill_in "Title", with: "Updated title"
        end

        click_button "Save card"

        expect(page).to have_current_path admin_site_customization_page_widget_cards_path(custom_page)
        expect(page).to have_content "Updated title"
        expect(page).not_to have_content "Original title"
      end

      scenario "Destroy" do
        create(:widget_card, cardable: custom_page, title: "Card title")

        visit admin_site_customization_page_widget_cards_path(custom_page)

        expect(page).to have_content("Card title")

        accept_confirm("Are you sure? This action will delete \"Card title\" and can't be undone.") do
          click_button "Delete"
        end

        expect(page).to have_current_path admin_site_customization_page_widget_cards_path(custom_page)
        expect(page).not_to have_content "Card title"
      end
    end
  end

  def attach_image_to_card
    click_link "Add image"
    attach_file "Choose image", file_fixture("clippy.jpg")

    expect(page).to have_field("widget_card_image_attributes_title", with: "clippy.jpg")
  end
end
