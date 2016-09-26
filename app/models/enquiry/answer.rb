class Enquiry::Answer < ActiveRecord::Base

  belongs_to :enquiry, -> { with_hidden }
  belongs_to :author, -> { with_hidden }, class_name: 'User', foreign_key: 'author_id'

  validates :enquiry, presence: true
  validates :author, presence: true
  validates :answer, presence: true
  validates :answer, inclusion: {in: ->(a) { a.enquiry.valid_answers }}

end
