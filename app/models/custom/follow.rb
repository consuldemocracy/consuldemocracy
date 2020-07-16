require_dependency Rails.root.join("app", "models", "follow").to_s

class Follow < ApplicationRecord
  validates :user_id, uniqueness: { scope: [:followable_id, :followable_type] }
end
