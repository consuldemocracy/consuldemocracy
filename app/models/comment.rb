class Comment < ActiveRecord::Base
  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases
  acts_as_votable
  has_ancestry

  attr_accessor :as_moderator, :as_administrator

  validates :body, presence: true
  validates :user, presence: true
  validates_inclusion_of :commentable_type, in: ["Debate"]

  belongs_to :commentable, -> { with_hidden }, polymorphic: true, counter_cache: true
  belongs_to :user, -> { with_hidden }

  has_many :flags, as: :flaggable

  scope :recent, -> { order(id: :desc) }

  scope :sort_for_moderation, -> { order(flags_count: :desc, updated_at: :desc) }
  scope :pending_flag_review, -> { where(ignored_flag_at: nil, hidden_at: nil) }
  scope :with_ignored_flag, -> { where("ignored_flag_at IS NOT NULL AND hidden_at IS NULL") }
  scope :flagged, -> { where("flags_count > 0") }

  scope :for_render, -> { with_hidden.includes(user: :organization) }

  after_create :call_after_commented

  def self.build(commentable, user, body, p_id=nil)
    new commentable: commentable,
        user_id:     user.id,
        body:        body,
        parent_id:   p_id
  end

  def self.find_commentable(c_type, c_id)
    c_type.constantize.find(c_id)
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

  def after_hide
    commentable_type.constantize.reset_counters(commentable_id, :comments)
  end

  def reply?
    !root?
  end

  def call_after_commented
    self.commentable.try(:after_commented)
  end

end
