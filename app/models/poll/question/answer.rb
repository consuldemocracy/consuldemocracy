class Poll::Question::Answer < ApplicationRecord
  include Galleryable
  include Documentable
  paginates_per 10

  translates :title,       touch: true
  translates :description, touch: true
  include Globalizable

  accepts_nested_attributes_for :documents, allow_destroy: true

  belongs_to :question, class_name: "Poll::Question"
  has_many :videos, class_name: "Poll::Question::Answer::Video", dependent: :destroy

  validates_translation :title, presence: true
  validates :given_order, presence: true, uniqueness: { scope: :question_id }

  scope :by_author, ->(author) { where(author: author) }
  scope :with_content, -> { where.not(id: without_content) }
  scope :without_content, -> do
    where(description: "")
      .left_joins(:images).where(images: { id: nil })
      .left_joins(:documents).where(documents: { id: nil })
      .left_joins(:videos).where(poll_question_answer_videos: { id: nil })
  end

  def self.order_answers(ordered_array)
    ordered_array.each_with_index do |answer_id, order|
      find(answer_id).update_column(:given_order, (order + 1))
    end
  end

  def self.last_position(question_id)
    where(question_id: question_id).maximum("given_order") || 0
  end

  def total_votes
    if question.votation_type.present? && question.votation_type.enum_type == "prioritized"
      total_votes_prioritized
    else
      Poll::Answer.where(question_id: question, answer: title).count +
        ::Poll::PartialResult.where(question: question).where(answer: title).sum(:amount)
    end
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
    if question.votation_type.present? && question.votation_type.enum_type == "prioritized"
      answers = question.question_answers.map do |answer|
        Poll::Answer.where(question_id: answer.question, answer: answer.title).sum(:value)
      end
      is_most_voted = answers.none? { |a| a > total_votes_prioritized }
    else
      answers = question.question_answers.map do |answer|
        Poll::Answer.where(question_id: answer.question, answer: answer.title).count
      end
      is_most_voted = answers.none? { |a| a > total_votes }
    end
    update!(most_voted: is_most_voted)
  end
end
