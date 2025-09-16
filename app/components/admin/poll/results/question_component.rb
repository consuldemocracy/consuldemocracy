class Admin::Poll::Results::QuestionComponent < ApplicationComponent
  attr_reader :question, :partial_results

  def initialize(question, partial_results)
    @question = question
    @partial_results = partial_results
  end

  def votes_for(option)
    grouped = by_answer[option.title] || []
    grouped.sum(&:amount)
  end

  private

    def by_answer
      @by_answer ||= partial_results.where(question: question).group_by(&:answer)
    end
end
