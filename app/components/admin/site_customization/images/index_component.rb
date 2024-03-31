class Admin::SiteCustomization::Images::IndexComponent < ApplicationComponent
  include Header
  attr_reader :images

  def initialize(images)
    @images = images
  end

  private

    def title
      t("admin.site_customization.images.index.title")
    end
end
