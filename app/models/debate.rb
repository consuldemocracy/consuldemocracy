require 'numeric'
class Debate < ActiveRecord::Base
  acts_as_votable
  acts_as_commentable
  acts_as_taggable
  
  belongs_to :author, class_name: 'User', foreign_key: 'author_id'

  validates :title, presence: true
  validates :description, presence: true
  validates :author, presence: true

  validates :terms_of_service, acceptance: { allow_nil: false }, on: :create

  def likes
    get_likes.size
  end

  def dislikes
    get_dislikes.size
  end

  def total_votes
    votes_for.size
  end

end