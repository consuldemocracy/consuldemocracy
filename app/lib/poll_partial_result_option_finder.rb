class PollPartialResultOptionFinder < PollOptionFinder
  private

    def existing_choices
      question.partial_results.where(option_id: nil).distinct.pluck(:answer)
    end
end
