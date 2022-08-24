module Types
  module Poll
    class QuestionAnswerType < Types::BaseObject
      field :id, ID, null: false
      field :title, String, null: true
      field :description, String, null: true

      field :total_votes, Integer, null: true
      field :total_votes_percentage, Float, null: true
    end
  end
end
