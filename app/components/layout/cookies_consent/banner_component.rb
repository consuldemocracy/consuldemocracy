class Layout::CookiesConsent::BannerComponent < ApplicationComponent
  def render?
    feature?(:cookies_consent)
  end
end
