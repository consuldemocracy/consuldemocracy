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

    render_inline Layout::CookiesConsent::ManagementComponent.new

    expect(page).to be_rendered
    expect(page).to have_css "h2", text: "Cookies management"
    expect(page).to have_link "More information about cookies", href: "/cookies_policy"
    expect(page).to have_css "h3", text: "Essential cookies"
    expect(page).to have_button "Accept essential cookies"
  end

  it "does not render a link when the setting `cookies_consent.more_info_link` is not defined" do
    Setting["cookies_consent.more_info_link"] = ""

    render_inline Layout::CookiesConsent::ManagementComponent.new

    expect(page).not_to have_link "More information about cookies"
    expect(page).to be_rendered
  end
end
