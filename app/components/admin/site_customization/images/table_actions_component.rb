class Admin::SiteCustomization::Images::TableActionsComponent < ApplicationComponent
  attr_reader :image

  def initialize(image)
    @image = image
  end
end
