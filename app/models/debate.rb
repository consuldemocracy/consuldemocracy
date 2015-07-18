class Debate < ActiveRecord::Base
  acts_as_commentable
  
  belongs_to :author, class_name: 'User', foreign_key: 'author_id'

  validates :title, presence: true
  validates :description, presence: true
  validates :author, presence: true

  validates :terms_of_service, acceptance: { allow_nil: false }, on: :create
end