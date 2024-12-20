require "rails_helper"

describe Layout::CookiesConsent::VendorsComponent do
  it "is not rendered when there is no vendor" do
    render_inline Layout::CookiesConsent::VendorsComponent.new

    expect(page).not_to have_css ".cookies-vendors"
  end

  it "is rendered vendors content when there are vendors" do
    create(:cookies_vendor, name: "Third party", cookie: "third_party")

    render_inline Layout::CookiesConsent::VendorsComponent.new

    expect(page).to have_css ".cookies-vendors"
    expect(page).to have_content "Third party"
    expect(page).to have_css ".switch-input[type='checkbox'][name='third_party']"
    expect(page).to have_button "Save preferences"
  end
end
