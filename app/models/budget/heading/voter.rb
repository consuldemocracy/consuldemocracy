class Budget::Heading::Voter < ActiveRecord::Base
  belongs_to :user
  belongs_to :budget_heading, class_name: "Budget::Heading"

  validates :user_id, presence: true
  validates :budget_heading_id, presence: true
end
