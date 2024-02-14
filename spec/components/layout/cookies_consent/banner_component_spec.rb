require "rails_helper"

describe Layout::CookiesConsent::BannerComponent do
  before { Setting["feature.cookies_consent"] = true }

  it "renders the banner when cookies were not accepted" do
    render_inline Layout::CookiesConsent::BannerComponent.new

    expect(page).to have_css(".cookies-consent-banner")
  end

  it "does not render the banner when cookies were accepted" do
    allow_any_instance_of(Layout::CookiesConsent::BannerComponent).to receive(:current_value).and_return("all")

    render_inline Layout::CookiesConsent::BannerComponent.new

    expect(page).not_to have_css(".cookies-consent-banner")
  end

  it "does not render the banner when third party cookies were rejected" do
    allow_any_instance_of(Layout::CookiesConsent::BannerComponent).to receive(:current_value).and_return("essential")

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

  it "renders the cookies consent rejection link when the setup page is enabled" do
    Setting["cookies_consent.setup_page"] = true

    render_inline Layout::CookiesConsent::BannerComponent.new

    expect(page).to have_button("Reject")

    Setting["cookies_consent.setup_page"] = false

    render_inline Layout::CookiesConsent::BannerComponent.new

    expect(page).not_to have_button("Reject")
  end

  context "when admin testing mode is enabled" do
    before { Setting["cookies_consent.admin_test_mode"] = true }

    it "shows the cookie banner to administrators" do
      sign_in(create(:administrator).user)

      render_inline Layout::CookiesConsent::BannerComponent.new

      expect(page).to have_css(".cookies-consent-banner")
    end

    it "does not show the cookie banner to common users" do
      sign_in(create(:user))

      render_inline Layout::CookiesConsent::BannerComponent.new

      expect(page).not_to have_css(".cookies-consent-banner")
    end

    it "does not show the cookie banner to anonymous users" do
      render_inline Layout::CookiesConsent::BannerComponent.new

      expect(page).not_to have_css(".cookies-consent-banner")
    end
  end
end
