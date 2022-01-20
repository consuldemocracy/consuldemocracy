module Types
  module Poll
    class QuestionAnswerAttributes < Types::BaseInputObject
      argument :title, String, required: false
      argument :description, String, required: true, validates: { allow_blank: false }
      argument :given_order, Integer, required: true
    end
  end
end
