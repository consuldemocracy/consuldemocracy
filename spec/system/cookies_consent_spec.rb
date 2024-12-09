require "rails_helper"

describe "Cookies consent" do
  before do
    Setting["feature.cookies_consent"] = true
    Setting["cookies_consent.version_name"] = "v1"
    script = "$('body').append('Running third party script');"
    create(:cookies_vendor, name: "Third party", cookie: "third_party", script: script)
  end

  context "Banner consent" do
    scenario "Hides the banner when accepting essential cookies and for consecutive visits" do
      visit root_path

      expect(cookie_by_name("cookies_consent_v1")).to be nil
      expect(cookie_by_name("third_party")).to be nil
      expect(page).not_to have_content "Running third party script"

      within ".cookies-consent-banner" do
        click_button "Accept essential cookies"
      end

      expect(cookie_by_name("cookies_consent_v1")[:value]).to eq "essential"
      expect(cookie_by_name("third_party")[:value]).to eq "false"
      expect(page).not_to have_content "Cookies policy"
      expect(page).not_to have_content "Running third party script"

      refresh

      expect(page).not_to have_content "Cookies policy"
      expect(page).not_to have_content "Running third party script"
    end

    scenario "Hides the banner when accepting all cookies and for consecutive visits" do
      visit root_path

      expect(cookie_by_name("cookies_consent_v1")).to be nil
      expect(cookie_by_name("third_party")).to be nil
      expect(page).not_to have_content "Running third party script"

      within ".cookies-consent-banner" do
        click_button "Accept all"
      end

      expect(cookie_by_name("cookies_consent_v1")[:value]).to eq "all"
      expect(cookie_by_name("third_party")[:value]).to eq "true"
      expect(page).not_to have_content "Cookies policy"
      expect(page).not_to have_content "Running third party script"

      refresh

      expect(page).not_to have_content "Cookies policy"
      expect(page).to have_content "Running third party script", count: 1
    end
  end

  context "Management modal" do
    scenario "Allow users to accept essential cookies and hide management modal" do
      visit root_path

      expect(cookie_by_name("cookies_consent_v1")).to be nil
      expect(cookie_by_name("third_party")).to be nil
      expect(page).not_to have_content "Running third party script"

      within ".cookies-consent-banner" do
        click_button "Manage cookies"
      end

      within ".cookies-consent-management" do
        click_button "Accept essential cookies"
      end

      expect(cookie_by_name("cookies_consent_v1")[:value]).to eq "essential"
      expect(cookie_by_name("third_party")[:value]).to eq "false"
      expect(page).not_to have_content "Cookies policy"
      expect(page).not_to have_content "Cookies management"
      expect(page).not_to have_content "Running third party script"

      refresh

      expect(page).not_to have_content "Cookies policy"
      expect(page).not_to have_content "Running third party script"
    end

    scenario "Allow users to accept all cookies from the cookies management modal" do
      visit root_path

      expect(cookie_by_name("cookies_consent_v1")).to be nil
      expect(cookie_by_name("third_party")).to be nil
      expect(page).not_to have_content "Running third party script"

      within ".cookies-consent-banner" do
        click_button "Manage cookies"
      end

      within ".cookies-consent-management" do
        click_button "Accept all"
      end

      expect(cookie_by_name("cookies_consent_v1")[:value]).to eq "all"
      expect(cookie_by_name("third_party")[:value]).to eq "true"
      expect(page).not_to have_content "Cookies policy"
      expect(page).not_to have_content "Cookies management"
      expect(page).not_to have_content "Running third party script"

      refresh

      expect(page).not_to have_content "Cookies policy"
      expect(page).to have_content "Running third party script", count: 1
    end

    scenario "Allow users to accept custom cookies from the cookies management modal" do
      visit root_path

      expect(cookie_by_name("cookies_consent_v1")).to be nil
      expect(cookie_by_name("third_party")).to be nil

      within ".cookies-consent-banner" do
        click_button "Manage cookies"
      end

      within ".cookies-consent-management" do
        expect(page).to have_unchecked_field "Third party", visible: :none
        find("label[for='third_party']").click
        expect(page).to have_checked_field "Third party", visible: :none

        click_button "Save preferences"
      end

      expect(cookie_by_name("cookies_consent_v1")[:value]).to eq "custom"
      expect(cookie_by_name("third_party")[:value]).to eq "true"
      expect(page).not_to have_content "Cookies policy"
      expect(page).not_to have_content "Cookies management"
      expect(page).not_to have_content "Running third party script"

      refresh

      expect(page).to have_content "Running third party script", count: 1
      expect(page).not_to have_content "Cookies policy"

      click_link "Manage cookies"

      within ".cookies-consent-management" do
        expect(page).to have_checked_field "third_party", visible: :none
        find("label[for='third_party']").click
        expect(page).to have_unchecked_field "third_party", visible: :none

        click_button "Save preferences"
      end

      expect(page).to have_content "Running third party script", count: 1

      refresh

      expect(page).not_to have_content "Running third party script"
    end
  end
end
