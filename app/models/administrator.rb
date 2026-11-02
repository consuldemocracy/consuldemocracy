class Administrator < ApplicationRecord
  include UserRole

  has_many :budget_administrators, dependent: :destroy
  scope :with_user, -> { includes(:user) }

  def description_or_name
    description.presence || name
  end

  def description_or_name_and_email
    "#{description_or_name} (#{email})"
  end
end
