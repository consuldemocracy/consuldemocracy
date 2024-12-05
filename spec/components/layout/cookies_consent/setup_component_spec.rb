require "rails_helper"

describe Layout::CookiesConsent::SetupComponent do
  before do
    Setting["feature.cookies_consent"] = true
    Setting["cookies_consent.setup_page"] = true
  end

  it "is rendered when the cookies consent and the cookies setup features are enabled" do
    render_inline Layout::CookiesConsent::SetupComponent.new

    expect(page).to have_css(".cookies-consent-setup")
  end

  it "is not rendered when the cookies consent feature is disabled" do
    Setting["feature.cookies_consent"] = false

    render_inline Layout::CookiesConsent::SetupComponent.new

    expect(page).not_to have_css(".cookies-consent-setup")
  end

  it "is not rendered when the cookies setup feature is disabled" do
    Setting["cookies_consent.setup_page"] = false

    render_inline Layout::CookiesConsent::SetupComponent.new

    expect(page).not_to have_css(".cookies-consent-setup")
  end

  it "is rendered when the admin test mode is enabled and the current_user is an administrator" do
    Setting["cookies_consent.admin_test_mode"] = true
    sign_in(create(:administrator).user)

    render_inline Layout::CookiesConsent::SetupComponent.new

    expect(page).to have_css(".cookies-consent-setup")
  end

  it "is not rendered when the admin testing mode is enabled and the current_user is not an administrator" do
    Setting["cookies_consent.admin_test_mode"] = true
    sign_in(create(:user))

    render_inline Layout::CookiesConsent::SetupComponent.new

    expect(page).not_to have_css(".cookies-consent-setup")
  end

  it "renders a link when the setting `cookies_consent.more_info_link` is defined" do
    Setting["cookies_consent.more_info_link"] = "/cookies_policy"

    render_inline Layout::CookiesConsent::SetupComponent.new

    expect(page).to have_link("More information", href: "/cookies_policy")
  end

  it "does not renders a link when the setting `cookies_consent.more_info_link` is not defined" do
    Setting["cookies_consent.more_info_link"] = ""

    render_inline Layout::CookiesConsent::SetupComponent.new

    expect(page).not_to have_link("More information")
  end
end
