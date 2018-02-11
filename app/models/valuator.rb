class Valuator < ActiveRecord::Base
  belongs_to :user, touch: true
  belongs_to :valuator_group

  delegate :name, :email, :name_and_email, to: :user

  has_many :valuation_assignments, dependent: :destroy
  has_many :spending_proposals, through: :valuation_assignments
  has_many :valuator_assignments, dependent: :destroy, class_name: 'Budget::ValuatorAssignment'
  has_many :investments, through: :valuator_assignments, class_name: 'Budget::Investment'

  validates :user_id, presence: true, uniqueness: true

  def description_or_email
    description.present? ? description : email
  end

  def description_or_name
    description.present? ? description : name
  end

  def assigned_investment_ids
    investment_ids + [valuator_group.try(:investment_ids)].flatten
  end

end
