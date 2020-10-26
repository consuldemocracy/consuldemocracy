require "rails_helper"

describe "Home" do
  context "For not logged users" do
    scenario "Welcome message" do
      visit root_path

      expect(page).to have_content "CONSUL"
    end

    scenario "Not display recommended section" do
      create(:debate)

      visit root_path

      expect(page).not_to have_content "Recommendations that may interest you"
    end
  end

  context "For signed in users" do
    describe "Recommended" do
      before do
        proposal = create(:proposal, tag_list: "Sport")
        user = create(:user, followables: [proposal])
        login_as(user)
      end

      scenario "Display recommended section when feature flag recommended is active" do
        create(:debate, tag_list: "Sport")

        visit root_path

        expect(page).to have_content "Recommendations that may interest you"
      end

      scenario "Not display recommended section when feature flag recommended is not active" do
        create(:debate, tag_list: "Sport")
        Setting["feature.user.recommendations"] = false

        visit root_path

        expect(page).not_to have_content "Recommendations that may interest you"
      end

      scenario "Display debates" do
        debate = create(:debate, tag_list: "Sport")

        visit root_path

        expect(page).to have_content debate.title
        expect(page).to have_content debate.description
      end

      scenario "Display all recommended debates link" do
        create(:debate, tag_list: "Sport")

        visit root_path

        expect(page).to have_link("All recommended debates", href: debates_path(order: "recommendations"))
      end

      scenario "Display proposal" do
        proposal = create(:proposal, tag_list: "Sport")

        visit root_path

        expect(page).to have_content proposal.title
        expect(page).to have_content proposal.description
      end

      scenario "Display all recommended proposals link" do
        create(:proposal, tag_list: "Sport")

        visit root_path

        expect(page).to have_link("All recommended proposals", href: proposals_path(order: "recommendations"))
      end

      scenario "Display orbit carrousel" do
        create_list(:debate, 3, tag_list: "Sport")

        visit root_path

        expect(page).to have_selector("li[data-slide='0']")
        expect(page).to have_selector("li[data-slide='1']", visible: :hidden)
        expect(page).to have_selector("li[data-slide='2']", visible: :hidden)
      end

      scenario "Display recommended show when click on carousel" do
        debate = create(:debate, tag_list: "Sport")

        visit root_path

        within("#section_recommended") do
          click_on debate.title
        end

        expect(page).to have_current_path(debate_path(debate))
      end

      scenario "Do not display recommended section when there are not debates and proposals" do
        visit root_path
        expect(page).not_to have_content "Recommendations that may interest you"
      end
    end
  end

  describe "IE alert" do
    scenario "IE visitors are presented with an alert until they close it", :page_driver do
      # Selenium API does not include page request/response inspection methods
      # so we must use Capybara::RackTest driver to set the browser's headers
      Capybara.current_session.driver.header(
        "User-Agent",
        "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.0)"
      )

      visit root_path
      expect(page).to have_xpath(ie_alert_box_xpath)
      expect(page.driver.request.cookies["ie_alert_closed"]).to be_nil

      # faking close button, since a normal find and click
      # will not work as the element is inside a HTML conditional comment
      page.driver.browser.set_cookie("ie_alert_closed=true")

      visit root_path
      expect(page).not_to have_xpath(ie_alert_box_xpath)
      expect(page.driver.request.cookies["ie_alert_closed"]).to eq("true")
    end

    scenario "non-IE visitors are not bothered with IE alerts", :page_driver do
      visit root_path
      expect(page).not_to have_xpath(ie_alert_box_xpath)
      expect(page.driver.request.cookies["ie_alert_closed"]).to be_nil
    end

    def ie_alert_box_xpath
      "/html/body/div[@class='wrapper ']/comment()[contains(.,'ie-callout')]"
    end
  end

  scenario "if there are cards, the 'featured' title will render" do
    create(:widget_card,
      title: "Card text",
      description: "Card description",
      link_text: "Link text",
      link_url: "consul.dev"
    )

    visit root_path

    expect(page).to have_css(".title", text: "Featured")
  end

  scenario "if there are no cards, the 'featured' title will not render" do
    visit root_path

    expect(page).not_to have_css(".title", text: "Featured")
  end
end
