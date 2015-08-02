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

  before_validation :sanitize_description

  def likes
    get_likes.size
  end

  def dislikes
    get_dislikes.size
  end

  def total_votes
    votes_for.size
  end

  def editable?
    total_votes == 0
  end

  def editable_by?(user)
    editable? && author == user
  end

  protected

  def sanitize_description
    self.description = WYSIWYGSanitizer.new.sanitize(description)
  end

end
