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
end
