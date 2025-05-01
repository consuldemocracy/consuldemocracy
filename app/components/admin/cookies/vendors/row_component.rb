class Admin::Cookies::Vendors::RowComponent < ApplicationComponent
  with_collection_parameter :vendor

  attr_reader :vendor

  def initialize(vendor:)
    @vendor = vendor
  end
end
