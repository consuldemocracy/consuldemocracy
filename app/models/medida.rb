require 'numeric'
class Medida < ActiveRecord::Base
  include Flaggable
  include Taggable
  include Conflictable
  include Measurable
  include Sanitizable

  apply_simple_captcha
  acts_as_votable
  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases

  belongs_to :author, -> { with_hidden }, class_name: 'User', foreign_key: 'author_id'
  has_many :comments, as: :commentable

  validates :title, presence: true
  validates :description, presence: true
  validates :author, presence: true

  validates :title, length: { in: 4..Medida.title_max_length }
  validates :description, length: { in: 10..Medida.description_max_length }

  validates :terms_of_service, acceptance: { allow_nil: false }, on: :create

  before_save :calculate_hot_score, :calculate_confidence_score

  scope :for_render, -> { includes(:tags) }
  scope :sort_by_hot_score , -> { order(hot_score: :desc) }
  scope :sort_by_confidence_score , -> { order(confidence_score: :desc) }
  scope :sort_by_created_at, -> { order(created_at: :desc) }
  scope :sort_by_most_commented, -> { order(comments_count: :desc) }
  scope :sort_by_random, -> { order("RANDOM()") }
  scope :sort_by_flags, -> { order(flags_count: :desc, updated_at: :desc) }

  # Ahoy setup
  visitable # Ahoy will automatically assign visit_id on create

  def description
    super.try :html_safe
  end

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
    total_votes <= Setting.value_for('max_votes_for_medida_edit').to_i
  end

  def editable_by?(user)
    editable? && author == user
  end

  def register_vote(user, vote_value)
    if votable_by?(user)
      Medida.increment_counter(:cached_anonymous_votes_total, id) if (user.unverified? && !user.voted_for?(self))
      vote_by(voter: user, vote: vote_value)
    end
  end

  def votable_by?(user)
    total_votes <= 100 ||
      !user.unverified? ||
      Setting.value_for('max_ratio_anon_votes_on_medidas').to_i == 100 ||
      anonymous_votes_ratio < Setting.value_for('max_ratio_anon_votes_on_medidas').to_i ||
      user.voted_for?(self)
  end

  def anonymous_votes_ratio
    return 0 if cached_votes_total == 0
    (cached_anonymous_votes_total.to_f / cached_votes_total) * 100
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
    return none unless terms.present?

    medida_ids = where("medidas.title ILIKE ? OR medidas.description ILIKE ?",
                       "%#{terms}%", "%#{terms}%").pluck(:id)
    tag_ids = tagged_with(terms, wild: true, any: true).pluck(:id)
    where(id: [medida_ids, tag_ids].flatten.compact)
  end

  def after_hide
    self.tags.each{ |t| t.decrement_custom_counter_for('Medida') }
  end

  def after_restore
    self.tags.each{ |t| t.increment_custom_counter_for('Medida') }
  end

end
