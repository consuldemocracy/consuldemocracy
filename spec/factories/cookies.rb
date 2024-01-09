FactoryBot.define do
  factory :cookies_vendor, class: "Cookies::Vendor" do
    name { "Vendor name" }
    cookie { "vendor_cookie" }
    description { "Vendor description" }
  end
end
