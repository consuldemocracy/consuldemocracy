class Layout::CookiesConsent::Vendors::ScriptsComponent < ApplicationComponent
  def vendors
    @vendors ||= ::Cookies::Vendor.all
  end

  def render?
    feature?(:cookies_consent) && vendors.any?
  end
end
