class VerifiedUser < ActiveRecord::Base
  scope :by_user,  ->(user)  { where(document_number: user.document_number) }

  scope :by_email, ->(email) { where(email: email) }
  scope :by_phone, ->(phone) { where(phone: phone) }

  def self.phone?(user)
    by_user(user).by_phone(user.unconfirmed_phone).first.present?
  end
end
