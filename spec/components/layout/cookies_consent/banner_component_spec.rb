require "rails_helper"

describe Layout::CookiesConsent::BannerComponent do
  before { Setting["feature.cookies_consent"] = true }

  it "does not render the banner when cookies were accepted" do
    vc_test_request.cookies[:cookies_consent] = "essential"

    render_inline Layout::CookiesConsent::BannerComponent.new

    expect(page).not_to be_rendered
  end

  it "does not render the banner when feature `cookies_consent` is disabled" do
    Setting["feature.cookies_consent"] = nil

    render_inline Layout::CookiesConsent::BannerComponent.new

    expect(page).not_to be_rendered
  end

  it "renders the banner content when feature `cookies_consent` is enabled and cookies were not accepted" do
    render_inline Layout::CookiesConsent::BannerComponent.new

    expect(page).to be_rendered
    expect(page).to have_css "h2", text: "Cookies policy"
    expect(page).to have_button "Accept essential cookies"
  end
end
