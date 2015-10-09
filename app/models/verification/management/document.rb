class Verification::Management::Document
  include ActiveModel::Model

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
    CensusApi.new.call(document_type, document_number).valid?
  end

  def verified?
    user? && user.level_three_verified?
  end

  def verify
    user.update(verified_at: Time.now) if user?
  end

end



