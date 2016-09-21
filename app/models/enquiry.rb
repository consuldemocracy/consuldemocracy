class Enquiry < ActiveRecord::Base
  include Measurable

  belongs_to :author, -> { with_hidden }, class_name: 'User', foreign_key: 'author_id'

  has_many :comments, as: :commentable
  has_and_belongs_to_many :geozones
  belongs_to :proposal

  validates :title, presence: true
  validates :question, presence: true
  validates :summary, presence: true
  validates :author, presence: true
  validates :open_at, presence: true
  validates :closed_at, presence: true, date: { after_or_equal_to: :open_at}

  validates :title, length: { in: 4..Enquiry.title_max_length }
  validates :description, length: { maximum: Enquiry.description_max_length }
  validates :question, length: { in: 10..Enquiry.question_max_length }

  scope :sort_for_list, -> { order('proposal_id IS NULL', :open_at, :closed_at)}
  scope :for_render, -> { includes(:author, :proposal) }

  def open?(timestamp = DateTime.now)
    open_at <= timestamp && timestamp <= closed_at
  end

end
