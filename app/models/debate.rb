require 'numeric'
class Debate < ActiveRecord::Base
  include Flaggable
  apply_simple_captcha

  acts_as_votable
  acts_as_taggable
  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases

  belongs_to :author, -> { with_hidden }, class_name: 'User', foreign_key: 'author_id'
  has_many :comments, as: :commentable

  validates :title, presence: true
  validates :description, presence: true
  validates :author, presence: true

  validate :validate_title_length
  validate :validate_description_length

  validates :terms_of_service, acceptance: { allow_nil: false }, on: :create

  before_validation :sanitize_description
  before_validation :sanitize_tag_list

  before_save :calculate_hot_score, :calculate_confidence_score

  scope :sort_for_moderation, -> { order(flags_count: :desc, updated_at: :desc) }
  scope :for_render, -> { includes(:tags) }
  scope :sort_by_hot_score , -> { order(hot_score: :desc) }
  scope :sort_by_confidence_score , -> { order(confidence_score: :desc) }
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

  def after_commented
    save # updates the hot_score because there is a before_save
  end

  def calculate_hot_score
    self.hot_score = ScoreCalculator.hot_score(created_at,
                                               cached_votes_total,
                                               cached_votes_up,
                                               comments_count)
  end

  def calculate_confidence_score
    self.confidence_score = ScoreCalculator.confidence_score(cached_votes_total,
                                                             cached_votes_up)
  end

  def self.search(terms)
    terms.present? ? where("title ILIKE ? OR description ILIKE ?", "%#{terms}%", "%#{terms}%") : none
  end

  def conflictive?
    return false unless flags_count > 0 && cached_votes_up > 0
    cached_votes_up/flags_count.to_f < 5
  end

  def after_hide
    self.tags.each{ |t| t.decrement_custom_counter_for('Debate') }
  end

  def after_restore
    self.tags.each{ |t| t.increment_custom_counter_for('Debate') }
  end

  def self.title_max_length
    @@title_max_length ||= self.columns.find { |c| c.name == 'title' }.limit || 80
  end

  def self.description_max_length
    6000
  end

  protected

    def sanitize_description
      self.description = WYSIWYGSanitizer.new.sanitize(description)
    end

    def sanitize_tag_list
      self.tag_list = TagSanitizer.new.sanitize_tag_list(self.tag_list)
    end

  private

    def validate_description_length
      validator = ActiveModel::Validations::LengthValidator.new(
        attributes: :description,
        minimum: 10,
        maximum: Debate.description_max_length)
      validator.validate(self)
    end

    def validate_title_length
      validator = ActiveModel::Validations::LengthValidator.new(
        attributes: :title,
        minimum: 4,
        maximum: Debate.title_max_length)
      validator.validate(self)
    end

end
