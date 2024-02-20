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
  let!(:budgets_feed)      { create(:widget_feed, kind: "budgets") }

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

    scenario "Proposals and debates" do
      3.times { create(:proposal) }
      3.times { create(:debate) }

      visit admin_homepage_path

      within("#widget_feed_#{proposals_feed.id}") do
        select "3", from: "widget_feed_limit"
        click_button "No"

        expect(page).to have_button "Yes"
      end

      within("#widget_feed_#{debates_feed.id}") do
        select "3", from: "widget_feed_limit"
        click_button "No"

        expect(page).to have_button "Yes"
      end

      visit root_path

      within("#feed_proposals") do
        expect(page).to have_content "Featured proposals"
        expect(page).to have_css(".proposal", count: 3)
      end

      within("#feed_debates") do
        expect(page).to have_content "Most active debates"
        expect(page).to have_css(".debate", count: 3)
      end
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
      expect(page).to have_content("Card1 text")
      expect(page).to have_content("Card1 description")
      expect(page).to have_content("Link1 text")
      expect(page).to have_link(href: "consul1.dev")
      expect(page).to have_css("img[alt='#{card1.image.title}']")
    end

    within("#widget_card_#{card2.id}") do
      expect(page).to have_content("CARD2 LABEL")
      expect(page).to have_content("Card2 text")
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
end
