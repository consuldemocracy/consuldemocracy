class Verification::Management::Document
  include ActiveModel::Model
  include ActiveModel::Dates

  attr_accessor :document_type
  attr_accessor :document_number

  validates :document_type, :document_number, presence: true

  delegate :username, :email, to: :user, allow_nil: true

  def user
    @user = User.by_document(document_type, document_number).first
  end

  def user?
    user.present?
  end

  def in_census?
    response = CensusApi.new.call(document_type, document_number)
    response.valid? && valid_age?(response)
  end

  def valid_age?(response)
    if under_sixteen?(response)
      errors.add(:age, true)
      return false
    else
      return true
    end
  end

  def under_sixteen?(response)
    16.years.ago < string_to_date(response.date_of_birth)
  end

  def verified?
    user? && user.level_three_verified?
  end

  def verify
    user.update(verified_at: Time.now) if user?
  end

end