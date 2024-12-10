require "rails_helper"

describe "Cookies consent" do
  before { Setting["feature.cookies_consent"] = true }

  scenario "Shows the cookies consent banner and for consecutive visits" do
    visit root_path

    expect(page).to have_css ".cookies-consent-banner"

    refresh

    expect(page).to have_css ".cookies-consent-banner"
  end
end
