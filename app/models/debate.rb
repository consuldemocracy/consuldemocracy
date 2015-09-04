require 'numeric'
class Debate < ActiveRecord::Base
  default_scope { order(created_at: :desc) }

  apply_simple_captcha
  TITLE_LENGTH = Debate.columns.find { |c| c.name == 'title' }.limit

  acts_as_votable
  acts_as_taggable
  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases

  belongs_to :author, -> { with_hidden }, class_name: 'User', foreign_key: 'author_id'
  has_many :flags, :as => :flaggable
  has_many :comments, as: :commentable

  validates :title, presence: true
  validates :description, presence: true
  validates :author, presence: true

  validates :terms_of_service, acceptance: { allow_nil: false }, on: :create

  before_validation :sanitize_description
  before_validation :sanitize_tag_list

  scope :sorted_for_moderation, -> { order(flags_count: :desc, updated_at: :desc) }
  scope :pending_flag_review, -> { where(ignored_flag_at: nil, hidden_at: nil) }
  scope :with_ignored_flag, -> { where("ignored_flag_at IS NOT NULL AND hidden_at IS NULL") }
  scope :flagged, -> { where("flags_count > 0") }
  scope :for_render, -> { includes(:tags) }
  scope :sort_by_score , -> { reorder(cached_votes_score: :desc) }
  scope :sort_by_created_at, -> { reorder(created_at: :desc) }
  scope :sort_by_most_commented, -> { reorder(comments_count: :desc) }
  scope :sort_by_random, -> { reorder("RANDOM()") }
  scope :sort_by_hot_score , -> { order(hot_score: :desc) }

  # Ahoy setup
  visitable # Ahoy will automatically assign visit_id on create

  def likes
    cached_votes_up
  end

  def dislikes
    cached_votes_down
  end

  def total_votes
    cached_votes_total
  end

  def total_anonymous_votes
    cached_anonymous_votes_total
  end

  def editable?
    total_votes == 0
  end

  def editable_by?(user)
    editable? && author == user
  end

  def register_vote(user, vote_value)
    if votable_by?(user)
      Debate.increment_counter(:cached_anonymous_votes_total, id) if (user.unverified? && !user.voted_for?(self))
      vote_by(voter: user, vote: vote_value)
    end
  end

  def votable_by?(user)
    total_votes <= 100 ||
      !user.unverified? ||
      Setting.value_for('max_ratio_anon_votes_on_debates').to_i == 100 ||
      anonymous_votes_ratio < Setting.value_for('max_ratio_anon_votes_on_debates').to_i ||
      user.voted_for?(self)
  end

  def anonymous_votes_ratio
    return 0 if cached_votes_total == 0
    (cached_anonymous_votes_total.to_f / cached_votes_total) * 100
  end

  def description
    super.try :html_safe
  end

  def tag_list_with_limit(limit = nil)
    tags.most_used(limit).pluck :name
  end

  def tags_count_out_of_limit(limit = nil)
    return 0 unless limit

    count = tags.count - limit
    count < 0 ? 0 : count
  end

  def ignored_flag?
    ignored_flag_at.present?
  end

  def ignore_flag
    update(ignored_flag_at: Time.now)
  end

  protected

  def sanitize_description
    self.description = WYSIWYGSanitizer.new.sanitize(description)
  end

  def sanitize_tag_list
    self.tag_list = TagSanitizer.new.sanitize_tag_list(self.tag_list)
  end

end
