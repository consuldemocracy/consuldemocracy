class Poll::Question::Answer < ActiveRecord::Base
  include Galleryable
  include Documentable
  documentable max_documents_allowed: 3,
               max_file_size: 20.megabytes,
               accepted_content_types: [ "application/pdf" ]
  accepts_nested_attributes_for :documents, allow_destroy: true

  belongs_to :question, class_name: 'Poll::Question', foreign_key: 'question_id'
  has_many :videos, class_name: 'Poll::Question::Answer::Video'

  validates :title, presence: true
  validates :given_order, presence: true, uniqueness: { scope: :question_id }

  before_validation :set_order, on: :create

  def description
    super.try :html_safe
  end

  def self.order_answers(ordered_array)
    ordered_array.each_with_index do |answer_id, order|
      find(answer_id).update_attribute(:given_order, (order + 1))
    end
  end

  def set_order
    self.given_order = self.class.last_position(question_id) + 1
  end

  def self.last_position(question_id)
    where(question_id: question_id).maximum('given_order') || 0
  end

  def total_votes
    total = Poll::Answer.where(question: question, answer: title).count
    # TODO: FIX THIS HARCODED STUFF PLEASE!! When Blank Answers come along specifically
    if title == 'En blanco'
      other_question = question.poll.questions.where.not(id: question.id)
      # We substract the number users that answered the other question from the number of users that answered the current option question
      blanks_count = Poll::Answer.where(question: question).count - Poll::Answer.where(question: other_question).count
      # A ZERO: Means all users answered both questions of the poll YAYY!
      # B POSITIVE: Means there were more answers on the other question than on this one, so this one has the "blanks by omission"
      # C NEGATIVE: You got it right?
      total += blanks_count if blanks_count.positive?
    end
    total
  end

  def most_voted?
    self.most_voted
  end

  def total_votes_percentage
    question.answers_total_votes == 0 ? 0 : (total_votes * 100) / question.answers_total_votes
  end

  def set_most_voted
    answers = question.question_answers
                  .map { |a| Poll::Answer.where(question_id: a.question, answer: a.title).count }
    is_most_voted = !answers.any?{ |a| a > self.total_votes }

    self.update(most_voted: is_most_voted)
  end
end
