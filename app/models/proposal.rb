class Proposal < ActiveRecord::Base
  apply_simple_captcha

  belongs_to :author, -> { with_hidden }, class_name: 'User', foreign_key: 'author_id'
  has_many :comments, as: :commentable
  has_many :flags, as: :flaggable

  acts_as_taggable

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

  def self.title_max_length
    @@title_max_length ||= self.columns.find { |c| c.name == 'title' }.limit || 80
  end

  def self.question_max_length
    140
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
