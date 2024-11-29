class Layout::CookiesConsent::BaseComponent < ApplicationComponent
  def render?
    feature?(:cookies_consent)
  end
end
