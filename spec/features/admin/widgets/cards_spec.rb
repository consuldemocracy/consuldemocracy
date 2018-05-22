require 'rails_helper'

feature 'Cards' do

  background do
    admin = create(:administrator).user
    login_as(admin)
  end

  scenario "Create", :js do
    visit admin_homepage_path
    click_link "Create card"

    fill_in "widget_card_title", with: "Card text"
    fill_in "widget_card_description", with: "Card description"
    fill_in "widget_card_link_text", with: "Link text"
    fill_in "widget_card_link_url", with: "consul.dev"
    attach_image_to_card
    click_button "Create Card"

    expect(page).to have_content "Success"
    expect(page).to have_css(".card", count: 1)

    card = Widget::Card.last
    within("#widget_card_#{card.id}") do
      expect(page).to have_content "Card text"
      expect(page).to have_content "Card description"
      expect(page).to have_content "Link text"
      expect(page).to have_content "consul.dev"
      expect(page).to have_css("img[alt='#{card.image.title}']")
    end
  end

  scenario "Index" do
    3.times { create(:widget_card) }

    visit admin_homepage_path

    expect(page).to have_css(".card", count: 3)

    cards = Widget::Card.all
    cards.each do |card|
      expect(page).to have_content card.title
      expect(page).to have_content card.description
      expect(page).to have_content card.link_text
      expect(page).to have_content card.link_url
      expect(page).to have_css("img[alt='#{card.image.title}']")
    end
  end

  scenario "Edit" do
    card = create(:widget_card)

    visit admin_homepage_path

    within("#widget_card_#{card.id}") do
      click_link "Edit"
    end

    fill_in "widget_card_title", with: "Card text updated"
    fill_in "widget_card_description", with: "Card description updated"
    fill_in "widget_card_link_text", with: "Link text updated"
    fill_in "widget_card_link_url", with: "consul.dev updated"
    click_button "Update Card"

    expect(page).to have_content "Updated"

    expect(page).to have_css(".card", count: 1)
    within("#widget_card_#{Widget::Card.last.id}") do
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
        click_link "Remove"
      end
    end

    expect(page).to have_content "Removed"
    expect(page).to have_css(".card", count: 0)
  end

  context "Header Card" do

    scenario "Create" do
      visit admin_homepage_path
      click_link "Create header"

      fill_in "widget_card_title", with: "Card text"
      fill_in "widget_card_description", with: "Card description"
      fill_in "widget_card_link_text", with: "Link text"
      fill_in "widget_card_link_url", with: "consul.dev"
      click_button "Create Card"

      expect(page).to have_content "Success"

      within("#header") do
        expect(page).to have_css(".card", count: 1)
        expect(page).to have_content "Card text"
        expect(page).to have_content "Card description"
        expect(page).to have_content "Link text"
        expect(page).to have_content "consul.dev"
      end

      within("#cards") do
        expect(page).to have_css(".card", count: 0)
      end
    end

  end

  pending "add image expectactions"

  def attach_image_to_card
    click_link "Add image"
    image_input = find(".image").find("input[type=file]", visible: false)
    attach_file(
      image_input[:id],
      Rails.root.join('spec/fixtures/files/clippy.jpg'),
      make_visible: true)
    expect(page).to have_field('widget_card_image_attributes_title', with: "clippy.jpg")
  end
end