class Cookies::Vendors::ScriptsComponent < ApplicationComponent
  def vendors
    @vendors ||= ::Cookies::Vendor.all
  end

  def render?
    vendors.any?
  end
end
