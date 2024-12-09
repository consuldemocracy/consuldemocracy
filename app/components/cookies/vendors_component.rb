class Cookies::VendorsComponent < ApplicationComponent
  delegate :cookies, :dom_id, to: :helpers

  def render?
    vendors.any?
  end

  def vendors
    Cookies::Vendor.all
  end

  def enabled?(vendor)
    cookies[vendor.cookie] == "true"
  end
end
