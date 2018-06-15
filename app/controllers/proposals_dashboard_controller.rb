# frozen_string_literal: true

# Proposals dashboard
class ProposalsDashboardController < ApplicationController
  before_action :authenticate_user!

  helper_method :proposal, :proposed_actions
  respond_to :html
  layout 'proposals_dashboard'

  def index
    authorize! :dashboard, proposal
  end

  def publish
    authorize! :publish, proposal

    proposal.publish
    redirect_to proposal_dashboard_index_path(proposal), notice: t('proposals.notice.published')
  end

  def execute
    authorize! :dashboard, proposal
    ProposalExecutedDashboardAction.create(proposal: proposal, proposal_dashboard_action: proposal_dashboard_action, executed_at: Time.now)
    redirect_to proposal_dashboard_index_path(proposal.to_param)
  end

  private

  def proposal_dashboard_action
    @proposal_dashboard_action ||= ProposalDashboardAction.find(params[:id])
  end

  def proposal
    @proposal ||= Proposal.find(params[:proposal_id])
  end

  def proposed_actions
    @proposed_actions ||= ProposalDashboardAction.proposed_actions.active_for(proposal)
  end
end
