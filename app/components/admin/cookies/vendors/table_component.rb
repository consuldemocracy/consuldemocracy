class Admin::Cookies::Vendors::TableComponent < ApplicationComponent
  private

    def vendors
      ::Cookies::Vendor.all
    end

    def attribute_name(attribute)
      ::Cookies::Vendor.human_attribute_name(attribute)
    end
end
