class Moderator < ActiveRecord::Base
  belongs_to :user, touch: true
  delegate :name, :email, to: :user

  validates :user_id, presence: true, uniqueness: true
end
