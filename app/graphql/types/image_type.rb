module Types
  class ImageType < Types::BaseObject
    IMAGE_SIZES = [:small, :medium, :large, :thumb].freeze

    field :id, ID, null: true
    field :title, String, null: true
    field :url, String, null: true

    IMAGE_SIZES.each do |size|
      field_name = "image_url_#{size}".to_sym
      field field_name, String, null: true
      define_method(field_name) { absolute_url(object&.attachment&.url(size)) }
    end

    def url
      absolute_url(object.attachment.url)
    end
  end
end
