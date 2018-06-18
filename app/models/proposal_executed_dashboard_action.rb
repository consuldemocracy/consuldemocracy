# frozen_string_literal: true

class ProposalExecutedDashboardAction < ActiveRecord::Base
  belongs_to :proposal
  belongs_to :proposal_dashboard_action

  has_many :administrator_tasks, as: :source, dependent: :destroy

  validates :proposal, presence: true, uniqueness: { scope: :proposal_dashboard_action }
  validates :proposal_dashboard_action, presence: true
  validates :executed_at, presence: true
  validates :comments, presence: true, allow_blank: false, if: :comments_required?

  def comments_required?
    proposal_dashboard_action&.request_to_administrators? || false
  end
end
