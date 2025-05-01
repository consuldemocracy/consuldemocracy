require "rails_helper"

describe Layout::CookiesConsent::VendorsComponent do
  before { Setting["feature.cookies_consent"] = true }

  it "is not rendered when there are no vendors" do
    render_inline Layout::CookiesConsent::VendorsComponent.new

    expect(page).not_to be_rendered
  end

  it "renders vendors content when there are vendors" do
    create(:cookies_vendor, name: "Vendor cookie", cookie: "third_party")

    render_inline Layout::CookiesConsent::VendorsComponent.new

    expect(page).to be_rendered
    expect(page).to have_content "Third party cookies"
    expect(page).to have_content "Vendor cookie"
    expect(page).to have_css ".switch-input[type='checkbox'][name='third_party']"
    expect(page).to have_button "Save preferences"
  end
end
