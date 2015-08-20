class Comment < ActiveRecord::Base
  include ActsAsParanoidAliases
  acts_as_nested_set scope: [:commentable_id, :commentable_type], counter_cache: :children_count

  acts_as_paranoid column: :hidden_at
  acts_as_votable

  validates :body, presence: true
  validates :user, presence: true

  belongs_to :commentable, polymorphic: true
  belongs_to :user

  has_many :inappropiate_flags, :as => :flaggable

  default_scope { includes(:user) }
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

  def total_votes
    votes_for.size
  end

  # TODO: faking counter cache since there is a bug with acts_as_nested_set :counter_cache
  # Remove when https://github.com/collectiveidea/awesome_nested_set/issues/294 is fixed
  # and reset counters using
  # > Comment.find_each { |comment| Comment.reset_counters(comment.id, :children) }
  def children_count
    children.count
  end

end
