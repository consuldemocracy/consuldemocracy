class Layout::CookiesConsent::VendorsComponent < Layout::CookiesConsent::BaseComponent
  delegate :cookies, :dom_id, to: :helpers

  def render?
    super && vendors.any?
  end

  def enabled?(vendor)
    cookies[vendor.cookie] == "true"
  end
end
