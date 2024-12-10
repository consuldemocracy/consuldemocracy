require "rails_helper"

describe "Cookies consent" do
  before { Setting["feature.cookies_consent"] = true }

  context "Banner consent" do
    scenario "Hides the banner when accept essential cookies and for consecutive visits" do
      visit root_path

      expect(cookie_by_name("cookies_consent")).to be nil

      within ".cookies-consent-banner" do
        click_button "Accept essential cookies"
      end

      expect(cookie_by_name("cookies_consent")[:value]).to eq "essential"
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

      within ".cookies-consent-banner" do
        click_button "Setup"
      end

      within ".cookies-consent-setup" do
        click_button "Accept essential cookies"
      end

      expect(cookie_by_name("cookies_consent")[:value]).to eq "essential"
      expect(page).not_to have_css ".cookies-consent-banner"
      expect(page).not_to have_css ".cookies-consent-setup"
      expect(page).to have_content "Your cookies preferences were saved."

      refresh

      expect(page).not_to have_css ".cookies-consent-banner"
    end
  end
end
