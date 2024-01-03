require "rails_helper"

describe "Cookies consent" do
  before { Setting["feature.cookies_consent"] = true }

  scenario "Is not shown when feature is disabled" do
    Setting["feature.cookies_consent"] = false

    visit root_path

    expect(page).not_to have_css(".cookies-consent-banner")
  end

  scenario "Hides the cookies consent banner when accepted and for consecutive visits" do
    visit root_path

    within ".cookies-consent-banner" do
      click_button "Accept"
    end

    expect(page).not_to have_css(".cookies-consent-banner")

    visit root_path

    expect(page).not_to have_css(".cookies-consent-banner")
  end

  context "when setup page is disabled" do
    before { Setting["cookies_consent.setup_page"] = false }

    scenario "does not show the notice with the instructions to edit cookies preferences" do
      visit root_path

      within ".cookies-consent-banner" do
        click_button "Accept"
      end

      expect(page).not_to have_css(".cookies-consent-banner")
      expect(page).not_to have_content("Your cookies preferences were saved!")
    end
  end

  context "when setup page is enabled" do
    before { Setting["cookies_consent.setup_page"] = true }

    scenario "Hides the cookies consent banner when rejected and for consecutive visits" do
      visit root_path

      within ".cookies-consent-banner" do
        click_button "Reject"
      end

      expect(page).not_to have_css(".cookies-consent-banner")

      visit root_path

      expect(page).not_to have_css(".cookies-consent-banner")
    end

    scenario "Shows a link to open the cookies setup modal" do
      visit root_path

      within ".cookies-consent-banner" do
        click_button "Setup"
      end

      expect(page).to have_css(".cookies-consent-setup")
      expect(page).to have_css("h2", text: "Cookies setup")
    end

    scenario "Allow users to accept all cookies from the cookies setup modal" do
      visit root_path

      within ".cookies-consent-banner" do
        click_button "Setup"
      end

      within ".cookies-consent-setup" do
        click_button "Accept all"
      end

      expect(page).not_to have_css(".cookies-consent-banner")
      expect(page).not_to have_css(".cookies-consent-setup")

      visit root_path

      expect(page).not_to have_css(".cookies-consent-banner")
    end

    scenario "Allow users to accept essential cookies from the cookies setup modal" do
      visit root_path

      within ".cookies-consent-banner" do
        click_button "Setup"
      end

      within ".cookies-consent-setup" do
        click_button "Accept essential cookies"
      end

      expect(page).not_to have_css(".cookies-consent-banner")
      expect(page).not_to have_css(".cookies-consent-setup")

      visit root_path

      expect(page).not_to have_css(".cookies-consent-banner")
    end

    scenario "shows a notice with instructions to edit cookies preferences" do
      visit root_path

      within ".cookies-consent-banner" do
        click_button ["Accept", "Reject"].sample
      end

      expect(page).to have_content("Your cookies preferences were saved! You can change them")
      expect(page).to have_content("anytime from the \"Cookies setup\" link in the page footer.")
    end
  end
end
