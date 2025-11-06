class Admin::SiteCustomization::Pages::FormComponent < ApplicationComponent
  include TranslatableFormHelper
  include GlobalizeHelper

  attr_reader :page

  def initialize(page)
    @page = page
  end

  private

    def attribute_name(attribute)
      SiteCustomization::Page.human_attribute_name(attribute)
    end
end
