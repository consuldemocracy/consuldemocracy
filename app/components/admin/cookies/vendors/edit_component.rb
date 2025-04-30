class Admin::Cookies::Vendors::EditComponent < ApplicationComponent
  include Header

  attr_reader :vendor

  def initialize(vendor)
    @vendor = vendor
  end

  private

    def title
      t("admin.cookies.vendors.edit.title")
    end
end
