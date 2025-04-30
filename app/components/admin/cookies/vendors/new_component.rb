class Admin::Cookies::Vendors::NewComponent < ApplicationComponent
  include Header

  attr_reader :vendor

  def initialize(vendor)
    @vendor = vendor
  end

  private

    def title
      t("admin.cookies.vendors.new.title")
    end
end
