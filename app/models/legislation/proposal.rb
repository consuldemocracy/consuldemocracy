class Legislation::Proposal < ActiveRecord::Base
  include ActsAsParanoidAliases
  include Flaggable
  include Taggable
  include Conflictable
  include Measurable
  include Sanitizable
  include Searchable
  include Filterable
  include Followable
  include Communitable
  include Documentable

  documentable max_documents_allowed: 3,
               max_file_size: 3.megabytes,
               accepted_content_types: [ "application/pdf" ]
  accepts_nested_attributes_for :documents, allow_destroy: true

  acts_as_votable
  acts_as_paranoid column: :hidden_at

  belongs_to :process, class_name: 'Legislation::Process', foreign_key: 'legislation_process_id'
  belongs_to :author, -> { with_hidden }, class_name: 'User', foreign_key: 'author_id'
  belongs_to :geozone
  has_many :comments, as: :commentable

  validates :title, presence: true
  validates :summary, presence: true
  validates :author, presence: true

  validates :title, length: { in: 4..Legislation::Proposal.title_max_length }
  validates :description, length: { maximum: Legislation::Proposal.description_max_length }

  validates :terms_of_service, acceptance: { allow_nil: false }, on: :create

  before_validation :set_responsible_name

  before_save :calculate_hot_score, :calculate_confidence_score

  scope :for_render, -> { includes(:tags) }
  scope :sort_by_hot_score, -> { reorder(hot_score: :desc) }
  scope :sort_by_confidence_score, -> { reorder(confidence_score: :desc) }
  scope :sort_by_created_at,       -> { reorder(created_at: :desc) }
  scope :sort_by_most_commented,   -> { reorder(comments_count: :desc) }
  scope :sort_by_random,           -> { reorder("RANDOM()") }
  scope :sort_by_flags,            -> { order(flags_count: :desc, updated_at: :desc) }
  scope :last_week,                -> { where("proposals.created_at >= ?", 7.days.ago)}

  def to_param
    "#{id}-#{title}".parameterize
  end

  def searchable_values
    { title              => 'A',
      question           => 'B',
      author.username    => 'B',
      tag_list.join(' ') => 'B',
      geozone.try(:name) => 'B',
      summary            => 'C',
      description        => 'D'}
  end

  def self.search(terms)
    by_code = search_by_code(terms.strip)
    by_code.present? ? by_code : pg_search(terms)
  end

  def self.search_by_code(terms)
    matched_code = match_code(terms)
    results = where(id: matched_code[1]) if matched_code
    return results if results.present? && results.first.code == terms
  end

  def self.match_code(terms)
    /\A#{Setting["proposal_code_prefix"]}-\d\d\d\d-\d\d-(\d*)\z/.match(terms)
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

  def voters
    User.active.where(id: votes_for.voters)
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
    vote_by(voter: user, vote: vote_value) if votable_by?(user)
  end

  def code
    "#{Setting['proposal_code_prefix']}-#{created_at.strftime('%Y-%m')}-#{id}"
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
    tags.each{ |t| t.decrement_custom_counter_for('LegislationProposal') }
  end

  def after_restore
    tags.each{ |t| t.increment_custom_counter_for('LegislationProposal') }
  end

  protected

    def set_responsible_name
      if author && author.document_number?
        self.responsible_name = author.document_number
      end
    end
end
