class Verification::Management::Document
  include ActiveModel::Model
  include ActiveModel::Dates

  attr_accessor :document_type, :document_number, :date_of_birth, :postal_code

  validates :document_type, :document_number, presence: true
  validates :date_of_birth, presence: true, if: -> { Setting.force_presence_date_of_birth? }
  validates :postal_code, presence: true, if: -> { Setting.force_presence_postal_code? }

  delegate :username, :email, to: :user, allow_nil: true

  def initialize(attrs = {})
    self.date_of_birth = parse_date("date_of_birth", attrs)
    attrs = remove_date("date_of_birth", attrs)
    super
  end

  def user
    @user = User.active.by_document(document_type, document_number).first
  end

  def user?
    user.present?
  end

  def in_census?
    response = CensusCaller.new.call(document_type, document_number, date_of_birth, postal_code)
    response.valid? && valid_age?(response)
  end

  def valid_age?(response)
    if under_age?(response)
      errors.add(:age, true)
      false
    else
      true
    end
  end

  def under_age?(response)
    response.date_of_birth.blank? || Age.in_years(response.date_of_birth) < User.minimum_required_age
  end

  def verified?
    user? && user.level_three_verified?
  end

  def verify
    user.update(verified_at: Time.current) if user?
  end
end
