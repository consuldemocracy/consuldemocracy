module Types
  module Poll
    class AnswerType < Types::BaseObject
      field :id, ID, null: false
      field :answer, String, null: true
    end
  end
end
