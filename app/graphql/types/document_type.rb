module Types
  class DocumentType < Types::BaseObject
    field :id, ID, null: true
    field :url, String, null: true

    def url
      object.attachment.url
    end
  end
end
