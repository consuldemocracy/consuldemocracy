class Manager < ActiveRecord::Base
  validates :username, presence: true, uniqueness: true
  validates :password_digest, presence: true

  has_secure_password

  def self.valid_auth?(username = nil, password = nil)
    return false unless username.present? && password.present?
    Manager.find_by(username: username).try(:authenticate, password).present?
  end

end