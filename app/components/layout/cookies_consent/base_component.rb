class Layout::CookiesConsent::BaseComponent < ApplicationComponent
  def render?
    feature?(:cookies_consent)
  end

  def more_info_link
    Setting["cookies_consent.more_info_link"]
  end

  def vendors
    Cookies::Vendor.all
  end
end
