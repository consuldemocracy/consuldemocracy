class Polls::Results::QuestionComponent < ApplicationComponent
  attr_reader :question
  use_helpers :number_to_stats_percentage

  def initialize(question)
    @question = question
  end

  def option_styles(option)
    "win" if most_voted_option?(option)
  end

  def most_voted_option?(option)
    option.id == question.most_voted_option_id
  end

  def number_with_percentage(number, percentage)
    safe_join([number, "(#{number_to_stats_percentage(percentage)})"], " ")
  end
end
