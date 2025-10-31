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

    def image_description(image)
      safe_join([
        tag.strong(image.name),
        tag.span(image_hint(image), id: dom_id(image, :hint))
      ], " ")
    end

    def image_hint(image)
      t("admin.site_customization.images.index.dimensions",
        width: image.required_width,
        height: image.required_height)
    end
end
