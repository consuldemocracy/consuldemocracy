require "rails_helper"

describe Layout::CookiesConsent::BannerComponent do
  before { Setting["feature.cookies_consent"] = true }

  it "does not render the banner when feature `cookies_consent` is disabled" do
    Setting["feature.cookies_consent"] = nil

    render_inline Layout::CookiesConsent::BannerComponent.new

    expect(page).not_to be_rendered
  end

  it "renders the banner content when feature `cookies_consent` is enabled" do
    render_inline Layout::CookiesConsent::BannerComponent.new

    expect(page).to be_rendered
    expect(page).to have_css "h2", text: "Cookies policy"
  end
end
