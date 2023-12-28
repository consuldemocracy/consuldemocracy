require "rails_helper"

describe Layout::CookiesConsent::BannerComponent do
  before { Setting["feature.cookies_consent"] = true }

  it "renders the banner when cookies were not accepted" do
    render_inline Layout::CookiesConsent::BannerComponent.new

    expect(page).to have_css(".cookies-consent-banner")
  end

  it "does not render the banner when cookies were accepted" do
    allow_any_instance_of(Layout::CookiesConsent::BannerComponent)
      .to receive(:missing_cookies_setup?).and_return(false)

    render_inline Layout::CookiesConsent::BannerComponent.new

    expect(page).not_to have_css(".cookies-consent-banner")
  end

  it "does not render the banner when feature `cookies_consent` is disabled" do
    Setting["feature.cookies_consent"] = nil

    render_inline Layout::CookiesConsent::BannerComponent.new

    expect(page).not_to have_css(".cookies-consent-banner")
  end

  it "renders a link when the setting `cookies_consent.more_info_link` is defined" do
    Setting["cookies_consent.more_info_link"] = "/cookies_policy"

    render_inline Layout::CookiesConsent::BannerComponent.new

    expect(page).to have_link("More information", href: "/cookies_policy")
  end

  it "does not renders a link when the setting `cookies_consent.more_info_link` is not defined" do
    Setting["cookies_consent.more_info_link"] = ""

    render_inline Layout::CookiesConsent::BannerComponent.new

    expect(page).not_to have_link("More information")
  end
end
