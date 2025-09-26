class Admin::Poll::Results::QuestionComponent < ApplicationComponent
  attr_reader :question, :partial_results

  def initialize(question, partial_results)
    @question = question
    @partial_results = partial_results
  end

  def votes_for(option)
    partial_results.where(option: option).sum(:amount)
  end
end
