class VerifiedUser < ApplicationRecord
  scope :by_user,  ->(user)  { where(document_number: user.document_number) }

  scope :by_email, ->(email) { where(email: email) }
  scope :by_phone, ->(phone) { where(phone: phone) }

  def self.phone?(user)
    by_user(user).by_phone(user.unconfirmed_phone).first.present?
  end
end

# == Schema Information
#
# Table name: verified_users
#
#  id              :integer          not null, primary key
#  document_number :string
#  document_type   :string
#  phone           :string
#  email           :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
