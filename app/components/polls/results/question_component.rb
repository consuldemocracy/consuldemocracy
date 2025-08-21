class Polls::Results::QuestionComponent < ApplicationComponent
  attr_reader :question

  def initialize(question)
    @question = question
  end

  def option_styles(option)
    "win" if most_voted_option?(option)
  end

  def most_voted_option?(option)
    question.most_voted_option_ids.include?(option.id)
  end
end
