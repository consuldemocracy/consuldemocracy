class Cookies::Vendors::ScriptsComponent < ApplicationComponent
  attr_reader :vendors

  def initialize
    @vendors = ::Cookies::Vendor.all
  end

  def render?
    feature?("feature.cookies_consent") && feature?("cookies_consent.setup_page") && vendors.any?
  end
end
