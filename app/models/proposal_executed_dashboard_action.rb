# frozen_string_literal: true

class ProposalExecutedDashboardAction < ActiveRecord::Base
  belongs_to :proposal
  belongs_to :proposal_dashboard_action

  validates :proposal, presence: true, uniqueness: { scope: :proposal_dashboard_action }
  validates :proposal_dashboard_action, presence: true
  validates :executed_at, presence: true
end
