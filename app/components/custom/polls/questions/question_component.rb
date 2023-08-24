class Polls::Questions::QuestionComponent < ApplicationComponent; end

require_dependency Rails.root.join("app", "components", "polls", "questions", "question_component").to_s

class Polls::Questions::QuestionComponent
  attr_reader :questions, :index

  def initialize(questions, question, index)
    @questions = questions
    @question = question
    @index = index
  end
end
