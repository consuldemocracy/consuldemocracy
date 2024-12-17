class Polls::Questions::QuestionComponent < ApplicationComponent
  attr_reader :question

  def initialize(question:)
    @question = question
  end

  def options_read_more_links
    safe_join(question.options_with_read_more.map do |option|
      link_to option.title, "#option_#{option.id}"
    end, ", ")
  end
end
