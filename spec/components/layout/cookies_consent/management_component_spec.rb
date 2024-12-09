require "rails_helper"

describe Layout::CookiesConsent::ManagementComponent do
  before { Setting["feature.cookies_consent"] = true }

  it "is not rendered when the cookies consent feature is disabled" do
    Setting["feature.cookies_consent"] = false

    render_inline Layout::CookiesConsent::ManagementComponent.new

    expect(page).not_to be_rendered
  end

  it "is rendered when the cookies consent is enabled" do
    Setting["cookies_consent.more_info_link"] = "/cookies_policy"
    create(:cookies_vendor)

    render_inline Layout::CookiesConsent::ManagementComponent.new

    expect(page).to be_rendered
    expect(page).to have_css "h2", text: "Cookies management"
    expect(page).to have_link "More information about cookies", href: "/cookies_policy"
    expect(page).to have_css "h3", text: "Essential cookies"
    expect(page).to have_css ".switch-input[type='checkbox'][name='essential_cookies'][disabled][checked]"
    expect(page).to have_css "h3", text: "Third party cookies"
    expect(page).to have_button "Accept all"
    expect(page).to have_button "Accept essential cookies"
  end

  it "does not render a link when the setting `cookies_consent.more_info_link` is not defined" do
    Setting["cookies_consent.more_info_link"] = ""

    render_inline Layout::CookiesConsent::ManagementComponent.new

    expect(page).not_to have_link "More information about cookies"
    expect(page).to be_rendered
  end

  it "does not render an `Accept all` button when there aren't any cookie vendors" do
    render_inline Layout::CookiesConsent::ManagementComponent.new

    expect(page).not_to have_button "Accept all"
    expect(page).to be_rendered
  end
end
