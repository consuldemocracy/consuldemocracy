class RelatedUser < ApplicationRecord
  belongs_to :user, -> { with_hidden }, class_name: "User", inverse_of: :related_users
  belongs_to :related_user, -> { with_hidden }, class_name: "User", inverse_of: :related_users

  default_scope -> { order(:created_at) }

  class << self
    def exists?(user_id, related_user_id)
      where(user_id: user_id, related_user_id: related_user_id).present?
    end
  end
end
