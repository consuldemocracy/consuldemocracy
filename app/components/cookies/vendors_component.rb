class Cookies::VendorsComponent < ApplicationComponent
  attr_reader :vendors
  delegate :cookies, :dom_id, to: :helpers

  def initialize(vendors)
    @vendors = vendors
  end

  def render?
    vendors.any?
  end

  def enabled?(vendor)
    cookies[vendor.cookie] == "true"
  end
end
