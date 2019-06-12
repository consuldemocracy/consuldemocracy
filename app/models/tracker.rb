class Tracker < ApplicationRecord
  belongs_to :user, touch: true

  delegate :name, :email, :name_and_email, to: :user

  has_many :tracker_assignments, dependent: :destroy, class_name: "Budget::TrackerAssignment"
  has_many :investments, through: :tracker_assignments, class_name: "Budget::Investment"

  validates :user_id, presence: true, uniqueness: true

  def description_or_email
    description.present? ? description : email
  end

  def description_or_name
    description.present? ? description : name
  end

  def assigned_investment_ids
    investment_ids
  end

  def investments_by_heading(params, budget)
    results = investments.by_budget(budget)
    if params[:heading_id].present?
      results = results.by_heading(params[:heading_id])
    end
    results
  end
end
