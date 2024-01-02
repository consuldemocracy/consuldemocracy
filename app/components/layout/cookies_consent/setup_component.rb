class Layout::CookiesConsent::SetupComponent < Layout::CookiesConsent::BaseComponent
  def render?
    super && feature?("cookies_consent.setup_page")
  end
end
