class Layout::CookiesConsent::SetupComponent < ApplicationComponent
  def render?
    feature?(:cookies_consent)
  end
end
