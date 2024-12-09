require "rails_helper"

describe Layout::CookiesConsent::BannerComponent do
  before { Setting["feature.cookies_consent"] = true }

  it "does not render the banner when cookies were accepted" do
    vc_test_request.cookies[:cookies_consent_v1] = "essential"

    render_inline Layout::CookiesConsent::BannerComponent.new

    expect(page).not_to be_rendered
  end

  it "does not render the banner when feature `cookies_consent` is disabled" do
    Setting["feature.cookies_consent"] = nil

    render_inline Layout::CookiesConsent::BannerComponent.new

    expect(page).not_to be_rendered
  end

  it "renders the banner content when feature `cookies_consent` is enabled and cookies were not accepted" do
    Setting["cookies_consent.more_info_link"] = "/cookies_policy"
    create(:cookies_vendor)

    render_inline Layout::CookiesConsent::BannerComponent.new

    expect(page).to be_rendered
    expect(page).to have_css "h2", text: "Cookies policy"
    expect(page).to have_link "More information about cookies", href: "/cookies_policy"
    expect(page).to have_button "Accept all"
    expect(page).to have_button "Accept essential cookies"
    expect(page).to have_button "Manage cookies"
  end

  it "does not render a link when the setting `cookies_consent.more_info_link` is not defined" do
    Setting["cookies_consent.more_info_link"] = ""

    render_inline Layout::CookiesConsent::BannerComponent.new

    expect(page).not_to have_link "More information about cookies"
    expect(page).to be_rendered
  end

  it "does not render an `Accept all` button when there aren't any cookie vendors" do
    render_inline Layout::CookiesConsent::BannerComponent.new

    expect(page).not_to have_button "Accept all"
    expect(page).to be_rendered
  end
end
