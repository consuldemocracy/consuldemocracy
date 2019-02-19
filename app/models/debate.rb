require 'numeric'
class Debate < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  include Flaggable
  include Taggable
  include Conflictable
  include Measurable
  include Sanitizable
  include Searchable
  include Filterable
  include HasPublicAuthor
  include Graphqlable
  include Relationable
  include Notifiable
  include Randomizable

  acts_as_votable
  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases

  belongs_to :author, -> { with_hidden }, class_name: 'User', foreign_key: 'author_id'
  belongs_to :geozone
  has_one :probe_option
  has_many :comments, as: :commentable

  validates :title, presence: true
  validates :description, presence: true
  validates :author, presence: true

  validates :title, length: { in: 4..Debate.title_max_length }
  validates :description, length: { in: 10..Debate.description_max_length }
  validates :comment_kind, inclusion: { in: ["comment", "question"] }

  validates :terms_of_service, acceptance: { allow_nil: false }, on: :create

  before_save :calculate_hot_score, :calculate_confidence_score
  before_save :set_comment_kind

  scope :for_render,               -> { includes(:tags, :probe_option, author: :organization) }
  scope :sort_by_hot_score,        -> { reorder(hot_score: :desc) }
  scope :sort_by_confidence_score, -> { reorder(confidence_score: :desc) }
  scope :sort_by_created_at,       -> { reorder(created_at: :desc) }
  scope :sort_by_most_commented,   -> { reorder(comments_count: :desc) }
  scope :sort_by_relevance,        -> { all }
  scope :sort_by_flags,            -> { order(flags_count: :desc, updated_at: :desc) }
  scope :sort_by_recommendations,  -> { order(cached_votes_total: :desc) }
  scope :last_week,                -> { where("created_at >= ?", 7.days.ago)}
  scope :featured,                 -> { where("featured_at is not null")}
  scope :not_probe,                -> { where.not(id: ProbeOption.pluck(:debate_id))}
  scope :public_for_api,           -> { all }

  # Ahoy setup
  visitable # Ahoy will automatically assign visit_id on create

  attr_accessor :link_required

  def url
    debate_path(self)
  end

  def self.recommendations(user)
    tagged_with(user.interests, any: true)
      .where("author_id != ?", user.id)
  end

  def searchable_values
    { title              => 'A',
      author.username    => 'B',
      tag_list.join(' ') => 'B',
      geozone.try(:name) => 'B',
      description        => 'D'
    }
  end

  def self.search(terms)
    pg_search(terms)
  end

  def to_param
    "#{id}-#{title}".parameterize
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

  def votes_score
    cached_votes_score
  end

  def total_anonymous_votes
    cached_anonymous_votes_total
  end

  def editable?
    total_votes <= Setting['max_votes_for_debate_edit'].to_i
  end

  def editable_by?(user)
    editable? && author == user
  end

  def register_vote(user, vote_value)
    if votable_by?(user)
      Debate.increment_counter(:cached_anonymous_votes_total, id) if user.unverified? && !user.voted_for?(self)
      vote_by(voter: user, vote: vote_value)
    end
  end

  def votable_by?(user)
    return false unless user
    return false if ProbeOption.where(debate: self).present?
    total_votes <= 100 ||
      !user.unverified? ||
      Setting['max_ratio_anon_votes_on_debates'].to_i == 100 ||
      anonymous_votes_ratio < Setting['max_ratio_anon_votes_on_debates'].to_i ||
      user.voted_for?(self)
  end

  def anonymous_votes_ratio
    return 0 if cached_votes_total == 0
    (cached_anonymous_votes_total.to_f / cached_votes_total) * 100
  end

  def after_commented
    save # update cache when it has a new comment
  end

  def calculate_hot_score
    self.hot_score = ScoreCalculator.hot_score(self)
  end

  def calculate_confidence_score
    self.confidence_score = ScoreCalculator.confidence_score(cached_votes_total,
                                                             cached_votes_up)
  end

  def after_hide
    tags.each{ |t| t.decrement_custom_counter_for('Debate') }
  end

  def after_restore
    tags.each{ |t| t.increment_custom_counter_for('Debate') }
  end

  def featured?
    featured_at.present?
  end

  def self.debates_orders(user)
    orders = %w{hot_score confidence_score created_at relevance}
    orders << "recommendations" if Setting['feature.user.recommendations_on_debates'] && user&.recommended_debates
    return orders
  end

  def set_comment_kind
    self.comment_kind ||= 'comment'
  end

  def self.open_plenary_winners
    where(comment_kind: 'question').first
                                   .comments
                                   .sort_by_most_voted
                                   .limit(5)
  end

  def self.public_columns_for_api
    %w[id
       title
       description
       created_at
       cached_votes_total
       cached_votes_up
       cached_votes_down
       comments_count
       hot_score
       confidence_score]
  end

  def public_for_api?
    hidden? ? false : true
  end

end
