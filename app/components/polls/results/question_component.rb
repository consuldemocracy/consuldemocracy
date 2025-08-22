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

  def essay_total_responses
    essay_answered_count + essay_unanswered_count
  end

  def essay_answered_count
    @essay_answered_count ||= question.answers.where.not(text_answer: [nil, ""]).count
  end

  def essay_unanswered_count
    valid_participants_count - essay_answered_count
  end

  def essay_answered_percentage
    return 0.0 if essay_total_responses.zero?

    (essay_answered_count * 100.0) / essay_total_responses
  end

  def essay_unanswered_percentage
    return 0.0 if essay_total_responses.zero?

    (essay_unanswered_count * 100.0) / essay_total_responses
  end

  def valid_participants_count
    @valid_participants_count ||= question.poll.answers.distinct.count(:author_id)
  end
end
