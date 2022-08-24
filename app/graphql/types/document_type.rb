module Types
  class DocumentType < Types::BaseObject
    field :id, ID, null: true
    field :title, String, null: true
    field :url, String, null: true

    def url
      attachment_url_for(object)
    end
  end
end
