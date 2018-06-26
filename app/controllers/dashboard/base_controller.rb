class Dashboard::BaseController < ApplicationController
  before_action :authenticate_user!

  helper_method :proposal, :proposed_actions, :resources

  respond_to :html
  layout 'proposals_dashboard'

  private

  def proposal
    @proposal ||= Proposal.find(params[:proposal_id])
  end

  def proposed_actions
    @proposed_actions ||= ProposalDashboardAction.proposed_actions.active_for(proposal)
  end

  def resources
    @resources ||= ProposalDashboardAction.resources.active_for(proposal)
  end
end
