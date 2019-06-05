require "rails_helper"

feature "Homepage" do

  background do
    admin = create(:administrator).user
    login_as(admin)

    Setting["feature.homepage.widgets.feeds.proposals"] = false
    Setting["feature.homepage.widgets.feeds.debates"] = false
    Setting["feature.homepage.widgets.feeds.processes"] = false
    Setting["feature.user.recommendations"] = false
  end

  let!(:proposals_feed)    { create(:widget_feed, kind: "proposals") }
  let!(:debates_feed)      { create(:widget_feed, kind: "debates") }
  let!(:processes_feed)    { create(:widget_feed, kind: "processes") }

  let(:user_recommendations) { Setting.where(key: "feature.user.recommendations").first }
  let(:user)                 { create(:user) }

  context "Header" do

    scenario "Admin menu links to homepage path" do

      visit new_admin_widget_card_path(header_card: true)

      click_link Setting["org_name"] + " Administration"

      expect(page).to have_current_path(admin_root_path)
    end
  end

  context "Feeds" do

    scenario "Proposals", :js do
      5.times { create(:proposal) }

      visit admin_homepage_path

      within("#widget_feed_#{proposals_feed.id}") do
        select "1", from: "widget_feed_limit"
        accept_confirm { click_button "Enable" }
      end

      visit root_path

      within("#feed_proposals") do
        expect(page).to have_content "Most active proposals"
        expect(page).to have_css(".proposal", count: 1)
      end

      expect(page).not_to have_css("#feed_proposals.medium-8")
    end

    scenario "Debates", :js do
      5.times { create(:debate) }

      visit admin_homepage_path
      within("#widget_feed_#{debates_feed.id}") do
        select "2", from: "widget_feed_limit"
        accept_confirm { click_button "Enable" }
      end

      visit root_path

      within("#feed_debates") do
        expect(page).to have_content "Most active debates"
        expect(page).to have_css(".debate", count: 2)
      end

      expect(page).not_to have_css("#feed_debates.medium-4")
    end

    scenario "Proposals and debates", :js do
      3.times { create(:proposal) }
      3.times { create(:debate) }

      visit admin_homepage_path

      within("#widget_feed_#{proposals_feed.id}") do
        select "3", from: "widget_feed_limit"
        accept_confirm { click_button "Enable" }
      end

      within("#widget_feed_#{debates_feed.id}") do
        select "3", from: "widget_feed_limit"
        accept_confirm { click_button "Enable" }
      end

      visit root_path

      within("#feed_proposals") do
        expect(page).to have_content "Most active proposals"
        expect(page).to have_css(".proposal", count: 3)
      end

      within("#feed_debates") do
        expect(page).to have_content "Most active debates"
        expect(page).to have_css(".debate", count: 3)
      end

      expect(page).to have_css("#feed_proposals.medium-8")
      expect(page).to have_css("#feed_debates.medium-4")
    end

    scenario "Processes", :js do
      5.times { create(:legislation_process) }

      visit admin_homepage_path
      within("#widget_feed_#{processes_feed.id}") do
        select "3", from: "widget_feed_limit"
        accept_confirm { click_button "Enable" }
      end

      visit root_path

      expect(page).to have_content "Open processes"
      expect(page).to have_css(".legislation_process", count: 3)
    end

    xscenario "Deactivate"

  end

  scenario "Cards" do
    card1 = create(:widget_card, label: "Card1 label",
                                 title: "Card1 text",
                                 description: "Card1 description",
                                 link_text: "Link1 text",
                                 link_url: "consul1.dev")

    card2 = create(:widget_card, label: "Card2 label",
                                 title: "Card2 text",
                                 description: "Card2 description",
                                 link_text: "Link2 text",
                                 link_url: "consul2.dev")

    visit root_path

    expect(page).to have_css(".card", count: 2)

    within("#widget_card_#{card1.id}") do
      expect(page).to have_content("Card1 label")
      expect(page).to have_content("Card1 text")
      expect(page).to have_content("Card1 description")
      expect(page).to have_content("Link1 text")
      expect(page).to have_link(href: "consul1.dev")
      expect(page).to have_css("img[alt='#{card1.image.title}']")
    end

    within("#widget_card_#{card2.id}") do
      expect(page).to have_content("Card2 label")
      expect(page).to have_content("Card2 text")
      expect(page).to have_content("Card2 description")
      expect(page).to have_content("Link2 text")
      expect(page).to have_link(href: "consul2.dev")
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
