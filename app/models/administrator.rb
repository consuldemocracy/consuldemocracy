class Administrator < ApplicationRecord
  belongs_to :user, touch: true
  delegate :name, :email, :name_and_email, to: :user

  validates :user_id, presence: true, uniqueness: true
end
