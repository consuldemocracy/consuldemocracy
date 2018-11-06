class ValuatorGroup < ActiveRecord::Base
  has_many :valuators
  has_many :valuator_group_assignments, dependent: :destroy, class_name: 'Budget::ValuatorGroupAssignment'
  has_many :investments, through: :valuator_group_assignments, class_name: 'Budget::Investment'

  validates :name, presence: true, uniqueness: true
end
