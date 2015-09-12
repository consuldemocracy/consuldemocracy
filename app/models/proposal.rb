class Proposal < ActiveRecord::Base
  apply_simple_captcha
  acts_as_votable
  acts_as_taggable

  belongs_to :author, -> { with_hidden }, class_name: 'User', foreign_key: 'author_id'
  has_many :comments, as: :commentable
  has_many :flags, as: :flaggable

  validates :title, presence: true
  validates :question, presence: true
  validates :description, presence: true
  validates :author, presence: true

  validate :validate_title_length
  validate :validate_question_length
  validate :validate_description_length

  validates :terms_of_service, acceptance: { allow_nil: false }, on: :create

  before_validation :sanitize_description
  before_validation :sanitize_tag_list

  scope :for_render, -> { includes(:tags) }
  scope :sort_by_hot_score , -> { order(hot_score: :desc) }
  scope :sort_by_confidence_score , -> { order(confidence_score: :desc) }
  scope :sort_by_created_at, -> { order(created_at: :desc) }
  scope :sort_by_most_commented, -> { order(comments_count: :desc) }
  scope :sort_by_random, -> { order("RANDOM()") }

  def total_votes
    cached_votes_up
  end

  def conflictive?
    return false unless flags_count > 0 && cached_votes_up > 0
    cached_votes_up/flags_count.to_f < 5
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

  def self.title_max_length
    @@title_max_length ||= self.columns.find { |c| c.name == 'title' }.limit || 80
  end

  def self.question_max_length
    140
  end

  def self.description_max_length
    6000
  end

  def editable?
    total_votes <= 1000
  end

  def editable_by?(user)
    editable? && author == user
  end

  def votable_by?(user)
    user.level_two_verified? || !user.voted_for?(self)
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

end
