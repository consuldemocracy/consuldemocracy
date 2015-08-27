class Comment < ActiveRecord::Base
  include ActsAsParanoidAliases
  acts_as_nested_set scope: [:commentable_id, :commentable_type], counter_cache: :children_count
  acts_as_paranoid column: :hidden_at
  acts_as_votable

  attr_accessor :as_moderator, :as_administrator

  validates :body, presence: true
  validates :user, presence: true

  belongs_to :commentable, polymorphic: true, counter_cache: true
  belongs_to :user, -> { with_hidden }

  has_many :flags, :as => :flaggable

  scope :recent, -> { order(id: :desc) }

  scope :sorted_for_moderation, -> { order(flags_count: :desc, updated_at: :desc) }
  scope :pending_flag_review, -> { where(ignored_flag_at: nil, hidden_at: nil) }
  scope :with_ignored_flag, -> { where("ignored_flag_at IS NOT NULL AND hidden_at IS NULL") }
  scope :flagged, -> { where("flags_count > 0") }

  scope :for_render, -> { with_hidden.includes(user: :organization) }

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

  def author_id
    user_id
  end

  def author
    user
  end

  def author=(author)
    self.user= author
  end

  def total_votes
    cached_votes_total
  end

  def total_likes
    cached_votes_up
  end

  def total_dislikes
    cached_votes_down
  end

  def not_visible?
    hidden? || user.hidden?
  end

  def ignored_flag?
    ignored_flag_at.present?
  end

  def ignore_flag
    update(ignored_flag_at: Time.now)
  end

  def as_administrator?
    administrator_id.present?
  end

  def as_moderator?
    moderator_id.present?
  end

  # TODO: faking counter cache since there is a bug with acts_as_nested_set :counter_cache
  # Remove when https://github.com/collectiveidea/awesome_nested_set/issues/294 is fixed
  # and reset counters using
  # > Comment.find_each { |comment| Comment.reset_counters(comment.id, :children) }
  def children_count
    children.count
  end

  def after_hide
    commentable_type.constantize.reset_counters(commentable_id, :comment_threads)
  end

end
