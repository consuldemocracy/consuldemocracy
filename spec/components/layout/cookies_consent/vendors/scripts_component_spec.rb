require "rails_helper"

describe Layout::CookiesConsent::Vendors::ScriptsComponent do
  before do
    Setting["feature.cookies_consent"] = true
  end

  it "is not rendered when there are no vendors" do
    render_inline Layout::CookiesConsent::Vendors::ScriptsComponent.new

    expect(page).not_to be_rendered
  end

  it "is not rendered when cookies consent feature is not enabled" do
    Setting["feature.cookies_consent"] = false
    create(:cookies_vendor, name: "Third party", cookie: "third_party", script: "alert('Welcome!')")

    render_inline Layout::CookiesConsent::Vendors::ScriptsComponent.new

    expect(page).not_to be_rendered
  end

  it "renders script for vendor" do
    create(:cookies_vendor, name: "Third party", cookie: "third_party", script: "alert('Welcome!')")

    render_inline Layout::CookiesConsent::Vendors::ScriptsComponent.new

    expect(page).to have_content "function third_party_script()"
    expect(page).to have_content "alert('Welcome!')"
    expect(page).to have_css "script", visible: :none
  end
end
