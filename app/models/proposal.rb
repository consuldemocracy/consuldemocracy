class Proposal < ActiveRecord::Base
  include Flaggable

  apply_simple_captcha
  acts_as_votable
  acts_as_taggable
  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases

  belongs_to :author, -> { with_hidden }, class_name: 'User', foreign_key: 'author_id'
  has_many :comments, as: :commentable

  validates :title, presence: true
  validates :question, presence: true
  validates :summary, presence: true
  validates :author, presence: true
  validates :responsible_name, presence: true

  validate :validate_title_length
  validate :validate_question_length
  validate :validate_description_length
  validate :validate_responsible_length

  validates :terms_of_service, acceptance: { allow_nil: false }, on: :create

  before_validation :sanitize_description
  before_validation :sanitize_tag_list
  before_validation :set_responsible_name

  before_save :calculate_hot_score, :calculate_confidence_score

  scope :for_render, -> { includes(:tags) }
  scope :sort_by_hot_score , -> { order(hot_score: :desc) }
  scope :sort_by_confidence_score , -> { order(confidence_score: :desc) }
  scope :sort_by_created_at, -> { order(created_at: :desc) }
  scope :sort_by_most_commented, -> { order(comments_count: :desc) }
  scope :sort_by_random, -> { order("RANDOM()") }
  scope :sort_by_flags, -> { order(flags_count: :desc, updated_at: :desc) }

  def total_votes
    cached_votes_up
  end

  def conflictive?
    return false unless flags_count > 0 && cached_votes_up > 0
    cached_votes_up/flags_count.to_f < 5
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

  def description
    super.try :html_safe
  end

  def editable?
    total_votes <= Setting.value_for("max_votes_for_proposal_edit").to_i
  end

  def editable_by?(user)
    author_id == user.id && editable?
  end

  def votable_by?(user)
    user.level_two_or_three_verified?
  end

  def register_vote(user, vote_value)
    if votable_by?(user)
      vote_by(voter: user, vote: vote_value)
    end
  end

  def code
    "#{Setting.value_for("proposal_code_prefix")}-#{created_at.strftime('%Y-%M')}-#{id}"
  end

  def after_commented
    save # updates the hot_score because there is a before_save
  end

  def calculate_hot_score
    self.hot_score = ScoreCalculator.hot_score(created_at,
                                               cached_votes_up,
                                               cached_votes_up,
                                               comments_count)
  end

  def calculate_confidence_score
    self.confidence_score = ScoreCalculator.confidence_score(cached_votes_up,
                                                             cached_votes_up)
  end

  def after_hide
    self.tags.each{ |t| t.decrement_custom_counter_for('Proposal') }
  end

  def after_restore
    self.tags.each{ |t| t.increment_custom_counter_for('Proposal') }
  end

  def self.title_max_length
    @@title_max_length ||= self.columns.find { |c| c.name == 'title' }.limit || 80
  end

  def self.question_max_length
    140
  end

  def self.description_max_length
    6000
  end

  def self.responsible_name_max_length
    60
  end

  def self.search(query)
    return none unless query.present?

    query = I18n.transliterate(query.strip)
    pattern = "%#{query}%"

    found_ids = where(%{ unaccent(proposals.title) ILIKE ? OR
                         unaccent(proposals.question) ILIKE ? OR
                         unaccent(proposals.description) ILIKE ? },
                      pattern,
                      pattern,
                      pattern).pluck(:id)

    tagged_ids = tagged_with(query, wild: true, any: true).pluck(:id)

    where(id: (found_ids | tagged_ids))
  end

  def self.votes_needed_for_success
    Setting.value_for('votes_for_proposal_success').to_i
  end

  protected

    def sanitize_description
      self.description = WYSIWYGSanitizer.new.sanitize(description)
    end

    def sanitize_tag_list
      self.tag_list = TagSanitizer.new.sanitize_tag_list(self.tag_list)
    end

    def set_responsible_name
      if author && author.level_two_or_three_verified?
        self.responsible_name = author.document_number
      end
    end

  private

    def validate_description_length
      validator = ActiveModel::Validations::LengthValidator.new(
        attributes: :description,
        maximum: Proposal.description_max_length)
      validator.validate(self)
    end

    def validate_title_length
      validator = ActiveModel::Validations::LengthValidator.new(
        attributes: :title,
        minimum: 4,
        maximum: Proposal.title_max_length)
      validator.validate(self)
    end

    def validate_question_length
      validator = ActiveModel::Validations::LengthValidator.new(
        attributes: :title,
        minimum: 10,
        maximum: Proposal.question_max_length)
      validator.validate(self)
    end

    def validate_responsible_length
      validator = ActiveModel::Validations::LengthValidator.new(
        attributes: :title,
        minimum: 6,
        maximum: Proposal.responsible_name_max_length)
      validator.validate(self)
    end

end
