class Verification::Email
  include ActiveModel::Model

  attr_accessor :verified_user, :recipient, :plain_token, :encrypted_token

  validates :verified_user, presence: true
  validates :recipient, presence: true

  def initialize(verified_user)
    @verified_user = verified_user
    @recipient = @verified_user.try(:email)
  end

  def save
    return false unless valid?

    generate_token
    user.update(email_verification_token: @plain_token)
  end

  def user
    User.where(document_number: verified_user.document_number).first
  end

  def generate_token
    @plain_token, @encrypted_token = Devise.token_generator.generate(User, :email_verification_token)
  end

  def self.find(user, token)
    valid_token?(user, token)
  end

  def self.valid_token?(user, token)
    Devise.token_generator.digest(User, :email_verification_token, user.email_verification_token) == token
  end

end
