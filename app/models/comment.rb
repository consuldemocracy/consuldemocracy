class Comment < ActiveRecord::Base
  acts_as_nested_set scope: [:commentable_id, :commentable_type]
  acts_as_votable

  validates :body, presence: true
  validates :user, presence: true

  belongs_to :commentable, polymorphic: true
  belongs_to :user

  scope :recent, -> { order(id: :desc) }

  def self.build(commentable, user, body)
    new commentable: commentable,
        user_id:     user.id,
        body:        body
  end

  def self.find_parent(params)
    params[:commentable_type].constantize.find(params[:commentable_id])
  end

  def debate
    commentable if commentable.class == Debate
  end

  def author
    user
  end

end
