class Polls::Results::QuestionComponent < ApplicationComponent
  attr_reader :question

  def initialize(question:)
    @question = question
  end

  def answer_styles(answer)
    "win" if most_voted_answer?(answer)
  end

  def most_voted_answer?(answer)
    answer.id == question.most_voted_answer_id
  end
end
