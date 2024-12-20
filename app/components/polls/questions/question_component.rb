class Polls::Questions::QuestionComponent < ApplicationComponent
  attr_reader :question
  use_helpers :can?, :current_user

  def initialize(question:)
    @question = question
  end

  def options_read_more_links
    safe_join(question.options_with_read_more.map do |option|
      if option.question.essay?
        link_to question.title, "#option_#{option.id}"
      else
        link_to option.title, "#option_#{option.id}"
      end
    end, ", ")
  end

  def checked?(question, option)
    question.answers.where(author: current_user, option: option).any?
  end

  def existing_answer(question, option)
    answer = question.answers.where(author: current_user, option: option).first
    if answer && answer.text_answer?
      return answer.text_answer
    end
    return ""
  end
end
