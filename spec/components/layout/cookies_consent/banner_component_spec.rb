require "rails_helper"

describe Layout::CookiesConsent::BannerComponent do
  before { Setting["feature.cookies_consent"] = true }

  it "does not render the banner when cookies were accepted" do
    allow_any_instance_of(Layout::CookiesConsent::BannerComponent).to receive(:cookies_consent_unset?)
                                                                  .and_return(false)

    render_inline Layout::CookiesConsent::BannerComponent.new

    expect(page).not_to have_css ".cookies-consent-banner"
  end

  it "does not render the banner when feature `cookies_consent` is disabled" do
    Setting["feature.cookies_consent"] = nil

    render_inline Layout::CookiesConsent::BannerComponent.new

    expect(page).not_to have_css ".cookies-consent-banner"
  end

  it "renders the banner content when feature `cookies_consent` is enabled and cookies were not accepted" do
    Setting["cookies_consent.more_info_link"] = "/cookies_policy"

    render_inline Layout::CookiesConsent::BannerComponent.new

    expect(page).to have_css ".cookies-consent-banner"
    expect(page).to have_css "h2", text: "Cookies policy"
    expect(page).to have_link "More information", href: "/cookies_policy"
    expect(page).to have_button "Accept all"
    expect(page).to have_button "Accept essential cookies"
    expect(page).to have_button "Setup"
  end

  it "does not renders a link when the setting `cookies_consent.more_info_link` is not defined" do
    Setting["cookies_consent.more_info_link"] = ""

    render_inline Layout::CookiesConsent::BannerComponent.new

    expect(page).not_to have_link "More information"
  end
end
