class Poll::Question::Answer < ActiveRecord::Base
  include StatsHelper
  include Galleryable
  include Documentable

  translates :title,       touch: true
  translates :description, touch: true
  include Globalizable

  documentable max_documents_allowed: 3,
               max_file_size: 20.megabytes,
               accepted_content_types: [ "application/pdf" ]
  accepts_nested_attributes_for :documents, allow_destroy: true

  belongs_to :question, class_name: 'Poll::Question', foreign_key: 'question_id'
  has_many :videos, class_name: 'Poll::Question::Answer::Video'

  validates_translation :title, presence: true
  validates :given_order, presence: true, uniqueness: { scope: :question_id }

  before_validation :set_order, on: :create

  def description
    self[:description].try :html_safe
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

  # Hardcoded Stuff for Madrid 11 Polls where there are only 2 Questions per Poll
  # FIXME: Implement the "Blank Answers" feature at Consul
  def total_votes
    total = if title == 'En blanco'
              web_voters = Poll::Voter.where(poll: question.poll, origin: 'web').count
              first_answer = Poll::Answer.where(answer: question.question_answers.where(given_order: 1).first.title, question: question).count
              second_answer = Poll::Answer.where(answer: question.question_answers.where(given_order: 2).first.title, question: question).count
              web_voters - first_answer - second_answer - Poll::Stats.new(question.poll).generate[:total_web_white]
            else
              Poll::Answer.where(question_id: question, answer: title).count
            end
    total + ::Poll::PartialResult.where(question: question).where(answer: title).sum(:amount)
  end

  def total_votes_percentage
    calculate_percentage(total_votes, question.answers_total_votes)
  end

end
