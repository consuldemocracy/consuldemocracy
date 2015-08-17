class Administrator < ActiveRecord::Base
  belongs_to :user
  delegate :name, :email, to: :user

  validates :user_id, presence: true, uniqueness: true
end
