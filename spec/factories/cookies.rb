FactoryBot.define do
  factory :cookies_vendor, class: "Cookies::Vendor" do
    name { "Vendor name" }
    sequence(:cookie) { |n| "vendor_cookie_#{n}" }
    description { "Vendor description" }
  end
end
