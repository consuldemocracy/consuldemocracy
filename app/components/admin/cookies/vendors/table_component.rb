class Admin::Cookies::Vendors::TableComponent < ApplicationComponent
  attr_reader :vendors

  def initialize
    @vendors = ::Cookies::Vendor.all
  end

  private

    def attribute_name(attribute)
      ::Cookies::Vendor.human_attribute_name(attribute)
    end
end
