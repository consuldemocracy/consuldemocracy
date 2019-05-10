class Verification::Management::Document
  include ActiveModel::Model
  include ActiveModel::Dates

  attr_accessor :document_type
  attr_accessor :document_number

  validates :document_type, :document_number, presence: true

  delegate :username, :email, to: :user, allow_nil: true

  def user
    @user = User.active.by_document(document_type, document_number).first
  end

  def user?
    user.present?
  end

  def in_census?
    response = CensusCaller.new.call(document_type, document_number)
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
