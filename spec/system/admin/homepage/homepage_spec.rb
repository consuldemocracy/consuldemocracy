require "rails_helper"

describe "Homepage", :admin do
  before do
    Setting["homepage.widgets.feeds.proposals"] = false
    Setting["homepage.widgets.feeds.debates"] = false
    Setting["homepage.widgets.feeds.processes"] = false
    Setting["homepage.widgets.feeds.budgets"] = false
    Setting["feature.user.recommendations"] = false
  end

  let!(:proposals_feed)    { create(:widget_feed, kind: "proposals") }
  let!(:debates_feed)      { create(:widget_feed, kind: "debates") }
  let!(:processes_feed)    { create(:widget_feed, kind: "processes") }
  let!(:budgets_feed)      { create(:widget_feed, kind: "budgets") }

  let(:user_recommendations) { Setting.find_by(key: "feature.user.recommendations") }
  let(:user)                 { create(:user) }

  context "Header" do
    scenario "Admin menu links to homepage path" do
      visit new_admin_widget_card_path(header_card: true)

      click_link "#{Setting["org_name"]} Administration"

      expect(page).to have_current_path(admin_root_path)
    end
  end

  context "Feeds" do
    scenario "Proposals" do
      5.times { create(:proposal) }

      visit admin_homepage_path

      within("#widget_feed_#{proposals_feed.id}") do
        select "1", from: "widget_feed_limit"
        click_button "No"

        expect(page).to have_button "Yes"
      end

      visit root_path

      within("#feed_proposals") do
        expect(page).to have_content "Featured proposals"
        expect(page).to have_css(".proposal", count: 1)
      end

      expect(page).not_to have_css("#feed_proposals.medium-8")
    end

    scenario "Debates" do
      5.times { create(:debate) }

      visit admin_homepage_path
      within("#widget_feed_#{debates_feed.id}") do
        select "2", from: "widget_feed_limit"
        click_button "No"

        expect(page).to have_button "Yes"
      end

      visit root_path

      within("#feed_debates") do
        expect(page).to have_content "Most active debates"
        expect(page).to have_css(".debate", count: 2)
      end

      expect(page).not_to have_css("#feed_debates.medium-4")
    end

    scenario "Processes" do
      5.times { create(:legislation_process) }

      visit admin_homepage_path
      within("#widget_feed_#{processes_feed.id}") do
        select "3", from: "widget_feed_limit"
        click_button "No"

        expect(page).to have_button "Yes"
      end

      visit root_path

      expect(page).to have_content "Open processes"
      expect(page).to have_css(".legislation-process", count: 3)
    end

    scenario "Budgets" do
      5.times { create(:budget) }

      visit admin_homepage_path

      within("#widget_feed_#{budgets_feed.id}") do
        select "2", from: "widget_feed_limit"
        click_button "No"

        expect(page).to have_button "Yes"
      end

      visit root_path

      within("#feed_budgets") do
        expect(page).to have_content "Participatory budgets"
        expect(page).to have_css(".budget", count: 2)
      end
    end

    scenario "Budget phase do not show links on phase description" do
      budget = create(:budget)

      visit admin_homepage_path
      within("#widget_feed_#{budgets_feed.id}") do
        select "3", from: "widget_feed_limit"
        click_button "No"

        expect(page).to have_button "Yes"
      end

      budget.current_phase.update!(description: "<p>Description of the phase with a link to "\
                                                "<a href=\"https://consul.dev\">CONSUL website</a>.</p>")

      visit root_path

      within("#feed_budgets") do
        expect(page).to have_content("Description of the phase with a link to CONSUL website")
        expect(page).not_to have_link("CONSUL website")
      end
    end

    scenario "Deactivate proposals" do
      Setting["homepage.widgets.feeds.proposals"] = true
      create(:proposal)

      visit admin_homepage_path

      within("#widget_feed_#{proposals_feed.id}") do
        click_button "Yes"

        expect(page).to have_button "No"
      end

      visit root_path

      expect(page).not_to have_content "Most active proposals"
    end

    scenario "Deactivate debates" do
      Setting["homepage.widgets.feeds.debates"] = true
      create(:debate)

      visit admin_homepage_path

      within("#widget_feed_#{debates_feed.id}") do
        click_button "Yes"

        expect(page).to have_button "No"
      end

      visit root_path

      expect(page).not_to have_content "Most active debates"
    end

    scenario "Deactivate processes" do
      Setting["homepage.widgets.feeds.processes"] = true
      create(:legislation_process)

      visit admin_homepage_path

      within("#widget_feed_#{processes_feed.id}") do
        click_button "Yes"

        expect(page).to have_button "No"
      end

      visit root_path

      expect(page).not_to have_content "Open processes"
    end
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
      expect(page).to have_content("CARD1 LABEL")
      expect(page).to have_content("CARD1 TEXT")
      expect(page).to have_content("Card1 description")
      expect(page).to have_content("Link1 text")
      expect(page).to have_link(href: "consul1.dev")
      expect(page).to have_css("img[alt='#{card1.image.title}']")
    end

    within("#widget_card_#{card2.id}") do
      expect(page).to have_content("CARD2 LABEL")
      expect(page).to have_content("CARD2 TEXT")
      expect(page).to have_content("Card2 description")
      expect(page).to have_content("Link2 text")
      expect(page).to have_link(href: "consul2.dev")
      expect(page).to have_css("img[alt='#{card2.image.title}']")
    end
  end

  scenario "Header card description allows wysiwyg content" do
    header = create(:widget_card, label: "Header", title: "Welcome!", header: true,
                    link_text: "Link text", link_url: "consul.dev",
                    description: "<h2>CONSUL</h2>&nbsp;<p><strong>Open-source software</strong></p>")

    visit admin_homepage_path

    within("#widget_card_#{header.id}") do
      expect(page).to have_content("Welcome!")
      expect(page).to have_content("CONSUL Open-source software")
      expect(page).to have_content("Link text")
      expect(page).to have_content("consul.dev")
      expect(page).not_to have_selector("h2", text: "CONSUL")
      expect(page).not_to have_selector("strong", text: "Open-source")
    end

    visit root_path

    within(".jumbo") do
      expect(page).to have_content("Welcome!")
      expect(page).to have_selector("h2", text: "CONSUL")
      expect(page).to have_selector("strong", text: "Open-source software")
      expect(page).to have_link("Link text", href: "consul.dev")
    end
  end

  scenario "Recomendations" do
    create(:proposal, tag_list: "Sport", followers: [user])
    create(:proposal, tag_list: "Sport")

    visit admin_homepage_path

    within("#edit_setting_#{user_recommendations.id}") do
      click_button "No"

      expect(page).to have_button "Yes"
    end

    login_as(user)
    visit root_path

    expect(page).to have_content("Recommendations that may interest you")
  end
end
