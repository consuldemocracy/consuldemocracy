class Valuator < ApplicationRecord
  include UserRole

  belongs_to :valuator_group
  has_many :valuator_assignments, dependent: :destroy, class_name: "Budget::ValuatorAssignment"
  has_many :investments, through: :valuator_assignments, class_name: "Budget::Investment"

  def description_or_email
    description.presence || email
  end

  def description_or_name
    description.presence || name
  end

  def assigned_investment_ids
    investment_ids + valuator_group&.investment_ids.to_a
  end
end
