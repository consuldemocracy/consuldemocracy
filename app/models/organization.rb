class Organization < ActiveRecord::Base

  include Graphqlable

  belongs_to :user, touch: true

  validates :name, presence: true
  validates :name, uniqueness: true
  validate  :validate_name_length
  validates :responsible_name, presence: true
  validate  :validate_responsible_name_length

  delegate :email, :phone_number, to: :user

  scope :pending, -> { where(verified_at: nil, rejected_at: nil) }
  scope :verified, -> { where.not(verified_at: nil).where("(rejected_at IS NULL or rejected_at < organizations.verified_at)") }
  scope :rejected, -> { where.not(rejected_at: nil).where("(organizations.verified_at IS NULL or organizations.verified_at < rejected_at)") }

  def verify
    update(verified_at: Time.current)
  end

  def reject
    update(rejected_at: Time.current)
  end

  def verified?
    verified_at.present? &&
      (rejected_at.blank? || rejected_at < verified_at)
  end

  def rejected?
    rejected_at.present? &&
      (verified_at.blank? || verified_at < rejected_at)
  end

  def self.search(text)
    if text.present?
      joins(:user).where("users.email = ? OR users.phone_number = ? OR organizations.name ILIKE ?", text, text, "%#{text}%")
    else
      none
    end
  end

  def self.name_max_length
    @@name_max_length ||= columns.find { |c| c.name == 'name' }.limit || 60
  end

  def self.responsible_name_max_length
    @@responsible_name_max_length ||= columns.find { |c| c.name == 'responsible_name' }.limit || 60
  end

  private

    def validate_name_length
      validator = ActiveModel::Validations::LengthValidator.new(
        attributes: :name,
        maximum: Organization.name_max_length)
      validator.validate(self)
    end

    def validate_responsible_name_length
      validator = ActiveModel::Validations::LengthValidator.new(
        attributes: :responsible_name,
        maximum: Organization.responsible_name_max_length)
      validator.validate(self)
    end

end
