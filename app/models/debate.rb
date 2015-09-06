require 'numeric'
class Debate < ActiveRecord::Base
  apply_simple_captcha
  TITLE_LENGTH = Debate.columns.find { |c| c.name == 'title' }.limit

  acts_as_votable
  acts_as_taggable
  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases

  belongs_to :author, -> { with_hidden }, class_name: 'User', foreign_key: 'author_id'
  has_many :comments, as: :commentable
  has_many :flags, as: :flaggable

  validates :title, presence: true
  validates :description, presence: true
  validates :author, presence: true

  validates :terms_of_service, acceptance: { allow_nil: false }, on: :create

  before_validation :sanitize_description
  before_validation :sanitize_tag_list

  before_save :calculate_hot_score

  scope :sort_for_moderation, -> { order(flags_count: :desc, updated_at: :desc) }
  scope :pending_flag_review, -> { where(ignored_flag_at: nil, hidden_at: nil) }
  scope :with_ignored_flag, -> { where("ignored_flag_at IS NOT NULL AND hidden_at IS NULL") }
  scope :flagged, -> { where("flags_count > 0") }
  scope :for_render, -> { includes(:tags) }
  scope :sort_by_hot_score , -> { order(hot_score: :desc) }
  scope :sort_by_score , -> { order(cached_votes_score: :desc) }
  scope :sort_by_created_at, -> { order(created_at: :desc) }
  scope :sort_by_most_commented, -> { order(comments_count: :desc) }
  scope :sort_by_random, -> { order("RANDOM()") }

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
    return tags if limit.blank?

    tags.sort{|a,b| b.taggings_count <=> a.taggings_count}[0, limit]
  end

  def tags_count_out_of_limit(limit = nil)
    return 0 unless limit

    count = tags.size - limit
    count < 0 ? 0 : count
  end

  def ignored_flag?
    ignored_flag_at.present?
  end

  def ignore_flag
    update(ignored_flag_at: Time.now)
  end

  def after_commented
    save # updates the hot_score because there is a before_save
  end

  def calculate_hot_score
    z          = 1.96 # Normal distribution with a confidence of 0.95
    time_unit  = 1.0 * 12.hours
    start      = Time.new(2015, 6, 15)
    comments_weight = 1.0/3 # 3 comments == 1 positive vote

    weighted_score = 0

    n = cached_votes_total + comments_weight * comments_count
    if n > 0 then
      pos = cached_votes_up + comments_weight * comments_count
      phat = 1.0 * pos / n
      weighted_score = (phat + z*z/(2*n) - z * Math.sqrt((phat*(1-phat)+z*z/(4*n))/n))/(1+z*z/n)
    end

    age_in_units = 1.0 * ((created_at || Time.now) - start) / time_unit

    self.hot_score = (age_in_units**3 + weighted_score * 1000).round
  end

  def self.search(terms)
    terms.present? ? where("title ILIKE ? OR description ILIKE ?", "%#{terms}%", "%#{terms}%") : none
  end

  protected

  def sanitize_description
    self.description = WYSIWYGSanitizer.new.sanitize(description)
  end

  def sanitize_tag_list
    self.tag_list = TagSanitizer.new.sanitize_tag_list(self.tag_list)
  end
end
