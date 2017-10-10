class Poll::Question::Answer < ActiveRecord::Base
  include Galleryable
  include Documentable
  documentable max_documents_allowed: 3,
               max_file_size: 3.megabytes,
               accepted_content_types: [ "application/pdf" ]
  accepts_nested_attributes_for :documents, allow_destroy: true

  belongs_to :question, class_name: 'Poll::Question', foreign_key: 'question_id'
  has_many :videos, class_name: 'Poll::Question::Answer::Video'

  validates :title, presence: true

  def description
    super.try :html_safe
  end

  def self.order_answers(ordered_array)
    ordered_array.each_with_index do |answer_id, order|
      answer = find(answer_id)
      answer.update_attribute(:given_order, (order + 1))
      answer.save
    end
  end

  def set_order
    last_position = Poll::Question::Answer.where(question_id: question_id).maximum("given_order") || 0
    next_position = last_position + 1
    update_attribute(:given_order, next_position)
  end
end
