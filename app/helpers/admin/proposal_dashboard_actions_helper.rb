# frozen_string_literal: true

module Admin::ProposalDashboardActionsHelper
  def active_human_readable(active)
    return t('admin.proposal_dashboard_actions.index.active') if active
    t('admin.proposal_dashboard_actions.index.inactive')
  end
end
