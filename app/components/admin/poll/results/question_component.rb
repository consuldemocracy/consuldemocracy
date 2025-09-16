class Admin::Poll::Results::QuestionComponent < ApplicationComponent
  attr_reader :question, :partial_results

  def initialize(question, partial_results)
    @question = question
    @partial_results = partial_results
  end

  def by_question
    @by_question ||= partial_results.group_by(&:question_id)
  end
end
