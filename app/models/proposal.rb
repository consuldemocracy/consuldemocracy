class Proposal < ActiveRecord::Base
  include Flaggable
  include Taggable
  include Conflictable
  include Measurable
  include Sanitizable
  include PgSearch
  include SearchCache
  include Filterable

  apply_simple_captcha
  acts_as_votable
  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases

  belongs_to :author, -> { with_hidden }, class_name: 'User', foreign_key: 'author_id'
  belongs_to :geozone
  has_many :comments, as: :commentable

  validates :title, presence: true
  validates :question, presence: true
  validates :summary, presence: true
  validates :author, presence: true
  validates :responsible_name, presence: true

  validates :title, length: { in: 4..Proposal.title_max_length }
  validates :description, length: { maximum: Proposal.description_max_length }
  validates :question, length: { in: 10..Proposal.question_max_length }
  validates :responsible_name, length: { in: 6..Proposal.responsible_name_max_length }

  validates :terms_of_service, acceptance: { allow_nil: false }, on: :create

  before_validation :set_responsible_name

  before_save :calculate_hot_score, :calculate_confidence_score

  scope :for_render,               -> { includes(:tags) }
  scope :sort_by_hot_score ,       -> { reorder(hot_score: :desc) }
  scope :sort_by_confidence_score, -> { reorder(confidence_score: :desc) }
  scope :sort_by_created_at,       -> { reorder(created_at: :desc) }
  scope :sort_by_most_commented,   -> { reorder(comments_count: :desc) }
  scope :sort_by_random,           -> { reorder("RANDOM()") }
  scope :sort_by_relevance ,       -> { all }
  scope :sort_by_flags,            -> { order(flags_count: :desc, updated_at: :desc) }
  scope :last_week,            -> { where("created_at >= ?", 7.days.ago)}

  pg_search_scope :pg_search, {
    against: {
      title:       'A',
      question:    'B',
      summary:     'C',
      description: 'D'
    },
    associated_against: {
      tags: :name
    },
    using: {
      tsearch: { dictionary: "spanish", tsvector_column: 'tsv' }
    },
    ignoring: :accents,
    ranked_by: '(:tsearch)',
    order_within_rank: "proposals.cached_votes_up DESC"
  }

  def searchable_values
    values = {
      title       => 'A',
      question    => 'B',
      summary     => 'C',
      description => 'D'
    }
    tag_list.each{ |tag| values[tag] = 'D' }
    values[author.username] = 'D'
    values[geozone.name] = 'D' if geozone.present?
    values
  end

  def self.search(terms)
    self.pg_search(terms)
  end

  def description
    super.try :html_safe
  end

  def total_votes
    cached_votes_up + physical_votes
  end

  def editable?
    total_votes <= Setting["max_votes_for_proposal_edit"].to_i
  end

  def editable_by?(user)
    author_id == user.id && editable?
  end

  def votable_by?(user)
    user && user.level_two_or_three_verified?
  end

  def register_vote(user, vote_value)
    if votable_by?(user)
      vote_by(voter: user, vote: vote_value)
    end
  end

  def code
    "#{Setting["proposal_code_prefix"]}-#{created_at.strftime('%Y-%m')}-#{id}"
  end

  def after_commented
    save # updates the hot_score because there is a before_save
  end

  def calculate_hot_score
    self.hot_score = ScoreCalculator.hot_score(created_at,
                                               total_votes,
                                               total_votes,
                                               comments_count)
  end

  def calculate_confidence_score
    self.confidence_score = ScoreCalculator.confidence_score(total_votes, total_votes)
  end

  def after_hide
    self.tags.each{ |t| t.decrement_custom_counter_for('Proposal') }
  end

  def after_restore
    self.tags.each{ |t| t.increment_custom_counter_for('Proposal') }
  end

  def self.votes_needed_for_success
    Setting['votes_for_proposal_success'].to_i
  end

  protected

    def set_responsible_name
      if author && author.document_number?
        self.responsible_name = author.document_number
      end
    end

end
