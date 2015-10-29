require 'rails_helper'

feature "Home" do

  feature "For not logged users" do
    scenario 'Welcome message' do
      visit root_path

      expect(page).to have_content "Love the city, and it will become a city you love"
    end
  end

  feature "For signed in users" do
    scenario 'Redirect to proposals' do
      login_as(create(:user))
      visit root_path

      expect(current_path).to eq proposals_path
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
      "/html/body/div[@class='wrapper']/comment()[contains(.,'ie-alert-box')]"
    end
  end
end
