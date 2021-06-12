class SDG::Manager < ApplicationRecord
  belongs_to :user, touch: true, inverse_of: :sdg_manager
  delegate :name, :email, to: :user

  validates :user_id, presence: true, uniqueness: true
end
