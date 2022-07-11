module Types
  class ImageType < Types::BaseObject
    IMAGE_SIZES = [:small, :medium, :large, :thumb].freeze

    field :id, ID, null: true
    field :title, String, null: true
    field :url, String, null: true

    # DEPRECATED api field used by SmartVillage App
    field :image_url_large, String, null: true, deprecation_reason: "Use 'url' field instead."

    def url
      attachment_url_for(object)
    end
  end
end
