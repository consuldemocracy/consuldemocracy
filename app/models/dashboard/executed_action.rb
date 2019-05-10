class Dashboard::ExecutedAction < ApplicationRecord
  belongs_to :proposal
  belongs_to :action, class_name: "Dashboard::Action"

  has_many :administrator_tasks, as: :source, dependent: :destroy,
                                              class_name: "Dashboard::AdministratorTask"

  validates :proposal, presence: true, uniqueness: { scope: :action }
  validates :action, presence: true
  validates :executed_at, presence: true
end
