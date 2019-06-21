class Poll::Question::Answer < ApplicationRecord
  include Galleryable
  include Documentable
  paginates_per 10

  translates :title,       touch: true
  translates :description, touch: true
  include Globalizable

  accepts_nested_attributes_for :documents, allow_destroy: true

  belongs_to :question, class_name: "Poll::Question", foreign_key: "question_id"
  has_many :videos, class_name: "Poll::Question::Answer::Video"

  validates_translation :title, presence: true
  validates :given_order, presence: true, uniqueness: { scope: :question_id }

  scope :by_author, -> (author) { where(author: author) }

  scope :visibles, -> { where(hidden: false) }

  def description
    self[:description].try :html_safe
  end

  def self.order_answers(ordered_array)
    ordered_array.each_with_index do |answer_id, order|
      find(answer_id).update_attribute(:given_order, (order + 1))
    end
  end

  def self.last_position(question_id)
    where(question_id: question_id).maximum("given_order") || 0
  end

  def total_votes
    if !question.votation_type.present?
      Poll::Answer.where(question_id: question, answer: title).count +
        ::Poll::PartialResult.where(question: question).where(answer: title).sum(:amount)
    else
      case question.votation_type.enum_type
      when "positive_negative_open"
        total_votes_positive_negative
      when "prioritized"
        total_votes_prioritized
      when "unique"
        Poll::Answer.where(question_id: question, answer: title).count +
          ::Poll::PartialResult.where(question: question).where(answer: title).sum(:amount)
      else
        Poll::Answer.where(question_id: question, answer: title).count
      end
    end
  end

  def total_votes_positive_negative
    count_positive_negative(self, true) - count_positive_negative(self, false)
  end

  def total_votes_prioritized
    Poll::Answer.where(question_id: question, answer: title).sum(:value)
  end

  def most_voted?
    most_voted
  end

  def total_votes_percentage
    question.answers_total_votes.zero? ? 0 : (total_votes * 100.0) / question.answers_total_votes
  end

  def set_most_voted
    if question.enum_type.nil?
      for_only_votes
    else
      case question.enum_type
      when "positive_negative_open"
        answers = question.question_answers.visibles
                    .map { |a| count_positive_negative(a, true) - count_positive_negative(a, false) }
        is_most_voted = answers.none? {|a| a > total_votes_positive_negative}
        update(most_voted: is_most_voted)
      when "prioritized"
        answers = question.question_answers.visibles
                    .map { |a| Poll::Answer.where(question_id: a.question, answer: a.title).sum(:value) }
        is_most_voted = answers.none? {|a| a > total_votes_prioritized}
        update(most_voted: is_most_voted)
      else
        for_only_votes
      end
    end
  end

  private

    def count_positive_negative(answer, value)
      Poll::Answer.where(question_id: answer.question, answer: answer.title, positive: value).count
    end

    def for_only_votes
      answers = question.question_answers.visibles
                  .map {|a| Poll::Answer.where(question_id: a.question, answer: a.title).count}
      is_most_voted = answers.none? {|a| a > total_votes}
      update(most_voted: is_most_voted)
    end

end
