require 'rails_helper'

feature 'Cards' do

  background do
    admin = create(:administrator).user
    login_as(admin)
  end

  it_behaves_like "translatable",
                  "widget_card",
                  "edit_admin_widget_card_path",
                  %w[title description link_text label]

  scenario "Create", :js do
    visit admin_homepage_path
    click_link "Create card"

    fill_in "Label (optional)", with: "Card label"
    fill_in "Title", with: "Card text"
    fill_in "Description", with: "Card description"
    fill_in "Link text", with: "Link text"
    fill_in "widget_card_link_url", with: "consul.dev"
    attach_image_to_card
    click_button "Create card"

    expect(page).to have_content "Success"
    expect(page).to have_css(".homepage-card", count: 1)

    card = Widget::Card.last
    within("#widget_card_#{card.id}") do
      expect(page).to have_content "Card label"
      expect(page).to have_content "Card text"
      expect(page).to have_content "Card description"
      expect(page).to have_content "Link text"
      expect(page).to have_content "consul.dev"
      expect(page).to have_link("Show image", href: card.image_url(:large))
    end
  end

  scenario "Index" do
    3.times { create(:widget_card) }

    visit admin_homepage_path

    expect(page).to have_css(".homepage-card", count: 3)

    cards = Widget::Card.all
    cards.each do |card|
      expect(page).to have_content card.title
      expect(page).to have_content card.description
      expect(page).to have_content card.link_text
      expect(page).to have_content card.link_url
      expect(page).to have_link("Show image", href: card.image_url(:large))
    end
  end

  scenario "Edit" do
    card = create(:widget_card)

    visit admin_homepage_path

    within("#widget_card_#{card.id}") do
      click_link "Edit"
    end

    within(".translatable-fields") do
      fill_in "Label (optional)", with: "Card label updated"
      fill_in "Title", with: "Card text updated"
      fill_in "Description", with: "Card description updated"
      fill_in "Link text", with: "Link text updated"
    end

    fill_in "widget_card_link_url", with: "consul.dev updated"
    click_button "Save card"

    expect(page).to have_content "Updated"

    expect(page).to have_css(".homepage-card", count: 1)
    within("#widget_card_#{Widget::Card.last.id}") do
      expect(page).to have_content "Card label updated"
      expect(page).to have_content "Card text updated"
      expect(page).to have_content "Card description updated"
      expect(page).to have_content "Link text updated"
      expect(page).to have_content "consul.dev updated"
    end
  end

  scenario "Remove", :js do
    card = create(:widget_card)

    visit admin_homepage_path

    within("#widget_card_#{card.id}") do
      accept_confirm do
        click_link "Delete"
      end
    end

    expect(page).to have_content "Removed"
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

      expect(page).to have_content "Success"

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

  end

  pending "add image expectactions"

  def attach_image_to_card
    click_link "Add image"
    image_input = all(".image").last.find("input[type=file]", visible: false)
    attach_file(
      image_input[:id],
      Rails.root.join('spec/fixtures/files/clippy.jpg'),
      make_visible: true)
    expect(page).to have_field('widget_card_image_attributes_title', with: "clippy.jpg")
  end
end
