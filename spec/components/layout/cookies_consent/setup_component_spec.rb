require "rails_helper"

describe Layout::CookiesConsent::SetupComponent do
  before { Setting["feature.cookies_consent"] = true }

  it "is not rendered when the cookies consent feature is disabled" do
    Setting["feature.cookies_consent"] = false

    render_inline Layout::CookiesConsent::SetupComponent.new

    expect(page).not_to have_css ".cookies-consent-setup"
  end

  it "is rendered setup content when the cookies consent is enabled" do
    Setting["cookies_consent.more_info_link"] = "/cookies_policy"

    render_inline Layout::CookiesConsent::SetupComponent.new

    expect(page).to have_css ".cookies-consent-setup"
    expect(page).to have_css "h2", text: "Cookies setup"
    expect(page).to have_link "More information", href: "/cookies_policy"
    expect(page).to have_css "h3", text: "Essential cookies"
    expect(page).to have_css ".switch-input[type='checkbox'][name='essential_cookies'][disabled][checked]"
    expect(page).to have_css "h3", text: "Third party cookies"
    expect(page).to have_button "Accept all"
    expect(page).to have_button "Accept essential cookies"
  end

  it "does not renders a link when the setting `cookies_consent.more_info_link` is not defined" do
    Setting["cookies_consent.more_info_link"] = ""

    render_inline Layout::CookiesConsent::SetupComponent.new

    expect(page).not_to have_link "More information"
  end
end
