class Layout::CookiesConsent::Vendors::ScriptsComponent < Layout::CookiesConsent::BaseComponent
  def render?
    super && vendors.any?
  end
end
