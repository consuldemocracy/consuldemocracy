require "rails_helper"

describe Cookies::VendorsComponent do
  it "is not rendered when there is no vendor" do
    render_inline Cookies::VendorsComponent.new

    expect(page).not_to have_css ".cookies-vendors"
  end

  it "is rendered vendors content when there are vendors" do
    create(:cookies_vendor)

    render_inline Cookies::VendorsComponent.new

    expect(page).to have_css ".cookies-vendors"
    expect(page).to have_content "Vendor name"
    expect(page).to have_css ".switch-input[type='checkbox'][name='vendor_cookie']"
    expect(page).to have_button "Save preferences"
  end
end
