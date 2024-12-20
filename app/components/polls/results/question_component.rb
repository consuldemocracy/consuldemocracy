class Polls::Results::QuestionComponent < ApplicationComponent
  attr_reader :question, :list_text_answers

  def initialize(question, list_text_answers = false)
    @question = question
    @list_text_answers = list_text_answers
  end

  def option_styles(option)
    "win" if most_voted_option?(option)
  end

  def most_voted_option?(option)
    option.id == question.most_voted_option_id
  end
end
