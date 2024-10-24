class Dashboard::AdministratorTask < ApplicationRecord
  belongs_to :source, polymorphic: true
  belongs_to :user

  validates :source, presence: true

  default_scope { order(created_at: :asc) }

  scope :done, -> { where.not(executed_at: nil) }
  scope :pending, -> { excluding(done) }

  def title
    "#{source.proposal.title} #{source.action.title}"
  end
end
