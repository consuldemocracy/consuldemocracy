require 'rails_helper'

feature "Home" do

  feature "For not logged users" do

    scenario 'Welcome message' do
      visit root_path

      expect(page).to have_content "Love the city, and it will become a city you love"
    end

    scenario 'Not display recommended section' do
      debate = create(:debate)

      visit root_path

      expect(page).not_to have_content "Recommendations that may interest you"
    end

  end

  feature "For signed in users" do

    feature "Recommended" do

      background do
        Setting['feature.user.recommendations'] = true
        user = create(:user)
        proposal = create(:proposal, tag_list: "Sport")
        create(:follow, followable: proposal, user: user)
        login_as(user)
      end

      after do
        Setting['feature.user.recommendations'] = nil
      end

      scenario 'Display recommended section' do
        debate = create(:debate, tag_list: "Sport")
        visit root_path
        expect(page).to have_content "Recommendations that may interest you"
      end

      scenario 'Display recommended section when feature flag recommended is active' do
        debate = create(:debate, tag_list: "Sport")
        visit root_path
        expect(page).to have_content "Recommendations that may interest you"
      end

      scenario 'Not display recommended section when feature flag recommended is not active' do
        debate = create(:debate, tag_list: "Sport")
        Setting['feature.user.recommendations'] = false

        visit root_path

        expect(page).not_to have_content "Recommendations that may interest you"
      end

      scenario 'Display debates' do
        debate = create(:debate, tag_list: "Sport")

        visit root_path

        expect(page).to have_content debate.title
        expect(page).to have_content debate.description
      end

      scenario 'Display all recommended debates link' do
        debate = create(:debate, tag_list: "Sport")
        visit root_path
        expect(page).to have_link("All recommended debates", href: debates_path(order: "recommendations"))
      end

      scenario 'Display proposal' do
        proposal = create(:proposal, tag_list: "Sport")

        visit root_path

        expect(page).to have_content proposal.title
        expect(page).to have_content proposal.description
      end

      scenario 'Display all recommended proposals link' do
        debate = create(:proposal, tag_list: "Sport")
        visit root_path
        expect(page).to have_link("All recommended proposals", href: proposals_path(order: "recommendations"))
      end

      scenario 'Display orbit carrousel' do
        create_list(:debate, 3, tag_list: "Sport")

        visit root_path

        expect(page).to have_selector('li[data-slide="0"]')
        expect(page).to have_selector('li[data-slide="1"]', visible: false)
        expect(page).to have_selector('li[data-slide="2"]', visible: false)
      end

      scenario 'Display recommended show when click on carousel' do
        debate = create(:debate, tag_list: "Sport")

        visit root_path
        click_on debate.title

        expect(current_path).to eq debate_path(debate)
      end

      scenario 'Do not display recommended section when there are not debates and proposals' do
        visit root_path
        expect(page).not_to have_content "Recommendations that may interest you"
      end

      feature 'Carousel size' do

        scenario 'Display debates centered when there are no proposals' do
          debate = create(:debate, tag_list: "Sport")
          visit root_path
          expect(page).to have_selector('.medium-centered.large-centered')
        end

        scenario 'Correct display debates and proposals' do
          proposal = create(:proposal, tag_list: "Sport")
          debates = create(:debate, tag_list: "Sport")

          visit root_path

          expect(page).to have_selector('.debates.medium-offset-2.large-offset-2')
          expect(page).not_to have_selector('.proposals.medium-offset-2.large-offset-2')
          expect(page).not_to have_selector('.debates.end')
          expect(page).to have_selector('.proposals.end')
          expect(page).not_to have_selector('.medium-centered.large-centered')
        end

      end
    end

  end

  feature 'IE alert' do
    scenario 'IE visitors are presented with an alert until they close it', :js do
      page.driver.headers = { "User-Agent" => "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.0)" }

      visit root_path
      expect(page).to have_xpath(ie_alert_box_xpath, visible: false)
      expect(page.driver.cookies['ie_alert_closed']).to be_nil

      # faking close button, since a normal find and click
      # will not work as the element is inside a HTML conditional comment
      page.driver.set_cookie 'ie_alert_closed', 'true'

      visit root_path
      expect(page).not_to have_xpath(ie_alert_box_xpath, visible: false)
      expect(page.driver.cookies["ie_alert_closed"].value).to eq('true')
    end

    scenario 'non-IE visitors are not bothered with IE alerts', :js do
      visit root_path
      expect(page).not_to have_xpath(ie_alert_box_xpath, visible: false)
      expect(page.driver.cookies['ie_alert_closed']).to be_nil
    end

    def ie_alert_box_xpath
      "/html/body/div[@class='wrapper ']/comment()[contains(.,'ie-callout')]"
    end
  end
end
