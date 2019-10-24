class Dashboard::ExecutedAction < ApplicationRecord
  belongs_to :proposal
  belongs_to :action

  has_many :administrator_tasks, as: :source, inverse_of: :source, dependent: :destroy

  validates :proposal, presence: true, uniqueness: { scope: :action }
  validates :action, presence: true
  validates :executed_at, presence: true
end
