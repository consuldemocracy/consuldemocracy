module Types
  class MilestoneType < Types::BaseObject
    field :title, String, null: true
    field :description, String, null: true
    field :id, ID, null: false
    field :date_of_publication, String, null: true

    def date_of_publication
      object.publication_date.to_date
    end
  end
end
