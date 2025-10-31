class PollOptionFinder
  attr_reader :question

  def initialize(question)
    @question = question
  end

  def manageable_choices
    choices_map.select { |choice, ids| ids.one? }
  end

  def unmanageable_choices
    choices_map.reject { |choice, ids| ids.one? }
  end

  private

    def choices_map
      @choices_map ||= existing_choices.to_h do |choice|
        [choice, options.where("lower(title) = lower(?)", choice).distinct.ids]
      end
    end

    def options
      question.question_options.joins(:translations).reorder(:id)
    end

    def existing_choices
      question.answers.where(option_id: nil).distinct.pluck(:answer)
    end
end
