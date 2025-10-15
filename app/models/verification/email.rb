class Verification::Email
  include ActiveModel::Model

  attr_accessor :verified_user, :recipient, :plain_token, :encrypted_token

  validates :verified_user, presence: true
  validates :recipient, presence: true

  def initialize(verified_user)
    @verified_user = verified_user
    @recipient = @verified_user&.email
    generate_token
  end

  def save
    return false unless valid?

    generate_token
    user.update!(email_verification_token: @plain_token)
  end

  def user
    User.find_by(document_number: verified_user.document_number)
  end

  def generate_token
    @encrypted_token, @plain_token = Devise.token_generator.generate(User, :email_verification_token)
  end

  def self.find(user, token)
    valid_token?(user, token)
  end

  def self.valid_token?(user, token)
    Devise.token_generator.digest(User, :email_verification_token, token) == user.email_verification_token
  end
end
