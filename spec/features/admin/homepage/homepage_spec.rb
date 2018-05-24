require 'rails_helper'

feature 'Homepage' do

  background do
    admin = create(:administrator).user
    login_as(admin)

    Setting['feature.homepage.widgets.feeds.proposals'] = false
    Setting['feature.homepage.widgets.feeds.debates'] = false
    Setting['feature.homepage.widgets.feeds.processes'] = false
    Setting['feature.user.recommendations'] = false
  end

  let(:proposals_setting)    { Setting.where(key: 'feature.homepage.widgets.feeds.proposals').first }
  let(:debates_setting)      { Setting.where(key: 'feature.homepage.widgets.feeds.debates').first }
  let(:processes_setting)    { Setting.where(key: 'feature.homepage.widgets.feeds.processes').first }
  let(:user_recommendations) { Setting.where(key: 'feature.user.recommendations').first }
  let(:user)                 { create(:user) }

  scenario "Header" do
  end

  context "Feeds" do

    scenario "Proposals" do
      5.times { create(:proposal) }

      visit admin_homepage_path
      within("#setting_#{proposals_setting.id}") do
        click_button "Enable"
      end

      expect(page).to have_content "Value updated"

      visit root_path

      expect(page).to have_content "Most active proposals"
      expect(page).to have_css(".proposal", count: 3)
    end

    scenario "Debates" do
      5.times { create(:debate) }

      visit admin_homepage_path
      within("#setting_#{debates_setting.id}") do
        click_button "Enable"
      end

      expect(page).to have_content "Value updated"

      visit root_path

      expect(page).to have_content "Most active debates"
      expect(page).to have_css(".debate", count: 3)
    end

    scenario "Processes" do
      5.times { create(:legislation_process) }

      visit admin_homepage_path
      within("#setting_#{processes_setting.id}") do
        click_button "Enable"
      end

      expect(page).to have_content "Value updated"

      visit root_path

      expect(page).to have_content "Most active processes"
      expect(page).to have_css(".legislation_process", count: 3)
    end

    xscenario "Deactivate"

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
      expect(page).to have_content("Link text")
      expect(page).to have_link(href: "consul.dev")
      expect(page).to have_css("img[alt='#{card1.image.title}']")
    end

    within("#widget_card_#{card2.id}") do
      expect(page).to have_content("Card text2")
      expect(page).to have_content("Card description2")
      expect(page).to have_content("Link text2")
      expect(page).to have_link(href: "consul.dev2")
      expect(page).to have_css("img[alt='#{card2.image.title}']")
    end
  end

  scenario "Recomendations" do
    proposal1 = create(:proposal, tag_list: "Sport")
    proposal2 = create(:proposal, tag_list: "Sport")
    create(:follow, followable: proposal1, user: user)

    visit admin_homepage_path
    within("#setting_#{user_recommendations.id}") do
      click_button "Enable"
    end

    expect(page).to have_content "Value updated"

    login_as(user)
    visit root_path

    expect(page).to have_content("Recommendations that may interest you")
  end

end