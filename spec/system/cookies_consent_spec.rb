require "rails_helper"

describe "Cookies consent" do
  before do
    Setting["feature.cookies_consent"] = true
    create(:cookies_vendor, name: "Third party", cookie: "third_party" )
  end

  context "Banner consent" do
    scenario "Hides the banner when accept essential cookies and for consecutive visits" do
      visit root_path

      expect(cookie_by_name("cookies_consent")).to be nil
      expect(cookie_by_name("third_party")).to be nil

      within ".cookies-consent-banner" do
        click_button "Accept essential cookies"
      end

      expect(cookie_by_name("cookies_consent")[:value]).to eq "essential"
      expect(cookie_by_name("third_party")[:value]).to eq "false"
      expect(page).not_to have_css ".cookies-consent-banner"
      expect(page).to have_content "Your cookies preferences were saved."

      refresh

      expect(page).not_to have_css ".cookies-consent-banner"
    end

    scenario "Hides the banner when accept all cookies and for consecutive visits" do
      visit root_path

      expect(cookie_by_name("cookies_consent")).to be nil
      expect(cookie_by_name("third_party")).to be nil

      within ".cookies-consent-banner" do
        click_button "Accept all"
      end

      expect(cookie_by_name("cookies_consent")[:value]).to eq "all"
      expect(cookie_by_name("third_party")[:value]).to eq "true"
      expect(page).not_to have_css ".cookies-consent-banner"
      expect(page).to have_content "Your cookies preferences were saved."

      refresh

      expect(page).not_to have_css ".cookies-consent-banner"
    end
  end

  context "Setup modal" do
    scenario "Allow users to accept essential cookies and hide setup modal" do
      visit root_path

      expect(cookie_by_name("cookies_consent")).to be nil
      expect(cookie_by_name("third_party")).to be nil

      within ".cookies-consent-banner" do
        click_button "Setup"
      end

      within ".cookies-consent-setup" do
        click_button "Accept essential cookies"
      end

      expect(cookie_by_name("cookies_consent")[:value]).to eq "essential"
      expect(cookie_by_name("third_party")[:value]).to eq "false"
      expect(page).not_to have_css ".cookies-consent-banner"
      expect(page).not_to have_css ".cookies-consent-setup"
      expect(page).to have_content "Your cookies preferences were saved."

      refresh

      expect(page).not_to have_css ".cookies-consent-banner"
    end

    scenario "Allow users to accept all cookies from the cookies setup modal" do
      visit root_path

      expect(cookie_by_name("cookies_consent")).to be nil
      expect(cookie_by_name("third_party")).to be nil

      within ".cookies-consent-banner" do
        click_button "Setup"
      end

      within ".cookies-consent-setup" do
        click_button "Accept all"
      end

      expect(cookie_by_name("cookies_consent")[:value]).to eq "all"
      expect(cookie_by_name("third_party")[:value]).to eq "true"
      expect(page).not_to have_css ".cookies-consent-banner"
      expect(page).not_to have_css ".cookies-consent-setup"
      expect(page).to have_content "Your cookies preferences were saved."

      refresh

      expect(page).not_to have_css ".cookies-consent-banner"
    end

    scenario "Allow users to accept custom cookies from the cookies setup modal" do
      visit root_path

      expect(cookie_by_name("cookies_consent")).to be nil
      expect(cookie_by_name("third_party")).to be nil

      within ".cookies-consent-banner" do
        click_button "Setup"
      end

      within ".cookies-consent-setup" do
        expect(find("label[for='third_party']")).not_to be_checked
        find("label[for='third_party']").click

        click_button "Save preferences"
      end

      expect(cookie_by_name("cookies_consent")[:value]).to eq "custom"
      expect(cookie_by_name("third_party")[:value]).to eq "true"
      expect(page).not_to have_css ".cookies-consent-banner"
      expect(page).not_to have_css ".cookies-consent-setup"
      expect(page).to have_content "Your cookies preferences were saved."

      refresh

      expect(page).not_to have_css ".cookies-consent-banner"
    end
  end
end
