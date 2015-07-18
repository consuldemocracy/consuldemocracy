class Debate < ActiveRecord::Base
  acts_as_commentable
  
  validates :title, presence: true
  validates :description, presence: true

  validates :terms_of_service, acceptance: { allow_nil: false }, on: :create
end
