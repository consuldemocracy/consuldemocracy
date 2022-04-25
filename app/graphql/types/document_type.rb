module Types
  class DocumentType < Types::BaseObject
    field :id, ID, null: true
    field :title, String, null: true
    field :url, String, null: true

    def url
      absolute_url(object.attachment.url)
    end
  end
end
