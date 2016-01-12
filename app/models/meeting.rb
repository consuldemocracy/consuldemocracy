class Meeting < ActiveRecord::Base
  belongs_to :author, -> { with_hidden }, class_name: 'User', foreign_key: 'author_id'

  validates :author, presence: true
  validates :title, presence: true
  validates :description, presence: true
  validates :address, presence: true
  validates :held_at, presence: true
  validates :start_at, presence: true
  validates :end_at, presence: true
end
