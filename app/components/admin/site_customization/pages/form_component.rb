class Admin::SiteCustomization::Pages::FormComponent < ApplicationComponent
  include TranslatableFormHelper
  include GlobalizeHelper
  attr_reader :page

  def initialize(page)
    @page = page
  end
end
