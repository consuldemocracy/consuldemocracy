module Types
  module Poll
    class QuestionAnswerType < Types::BaseObject
      field :id, ID, null: false
      field :title, String, null: true
      field :description, String, null: true
    end
  end
end
