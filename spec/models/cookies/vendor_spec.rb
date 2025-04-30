require "rails_helper"

describe Cookies::Vendor do
  let(:cookies_vendor) { build(:cookies_vendor) }

  it "is valid" do
    expect(cookies_vendor).to be_valid
  end

  it "is not valid without a name" do
    cookies_vendor.name = nil

    expect(cookies_vendor).not_to be_valid
  end

  it "is not valid without the cookie name" do
    cookies_vendor.cookie = nil

    expect(cookies_vendor).not_to be_valid
  end

  it "is not valid when cookie_name contains whitespaces, special characters" do
    cookies_vendor.cookie = "cookie vendor name"

    expect(cookies_vendor).not_to be_valid

    cookies_vendor.cookie = "cookie_vendor/name"

    expect(cookies_vendor).not_to be_valid

    cookies_vendor.cookie = "cookie_vendor_name"

    expect(cookies_vendor).to be_valid
  end

  it "is not valid when the cookie name already exists" do
    create(:cookies_vendor, cookie: "existing_name")

    cookies_vendor.cookie = "existing_name"

    expect(cookies_vendor).not_to be_valid
  end
end
