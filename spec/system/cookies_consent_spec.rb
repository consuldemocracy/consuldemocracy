require "rails_helper"

describe "Cookies consent" do
  before { Setting["feature.cookies_consent"] = true }

  scenario "Hides the cookies consent banner when accepted and for consecutive visits" do
    visit root_path

    within ".cookies-consent-banner" do
      click_button "Accept essential cookies"
    end

    expect(page).not_to have_css ".cookies-consent-banner"

    refresh

    expect(page).not_to have_css ".cookies-consent-banner"
  end
end
