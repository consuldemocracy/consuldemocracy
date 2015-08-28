# make sure document_type is being stored and queried in the correct format (Is it DNI? a number, a string?)
class VerifiedUser < ActiveRecord::Base
  scope :by_user,  -> (user)  { where(document_number: user.document_number,
                                      document_type:   user.document_type) }

  scope :by_email, -> (email) { where(email: email) }
  scope :by_phone, -> (phone) { where(phone: phone) }

  def self.phone?(user)
    by_user(user).by_phone(user.unconfirmed_phone).first.present?
  end
end
