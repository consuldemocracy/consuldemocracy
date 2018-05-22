require 'rails_helper'

feature 'Homepage' do

  background do
    admin = create(:administrator).user
    login_as(admin)

  end
  scenario "Header" do
  end

  scenario "Cards" do
    card1 = create(:widget_card, title: "Card text",
                                 description: "Card description",
                                 link_text: "Link text",
                                 link_url: "consul.dev")

    card2 = create(:widget_card, title: "Card text2",
                                 description: "Card description2",
                                 link_text: "Link text2",
                                 link_url: "consul.dev2")

    visit root_path

    expect(page).to have_css(".card", count: 2)

    within("#widget_card_#{card1.id}") do
      expect(page).to have_content("Card text")
      expect(page).to have_content("Card description")
      expect(page).to have_link("Link text", href: "consul.dev")
      expect(page).to have_css("img[alt='#{card1.image.title}']")
    end

    within("#widget_card_#{card2.id}") do
      expect(page).to have_content("Card text2")
      expect(page).to have_content("Card description2")
      expect(page).to have_link("Link text2", href: "consul.dev2")
      expect(page).to have_css("img[alt='#{card2.image.title}']")
    end
  end
