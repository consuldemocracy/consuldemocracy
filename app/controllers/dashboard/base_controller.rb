class Dashboard::BaseController < ApplicationController
  before_action :authenticate_user!

  helper_method :proposal, :proposed_actions, :resource, :resources, :next_goal_supports, :next_goal_progress

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

  def next_goal_supports
    @next_goal_supports ||= ProposalDashboardAction.next_goal_for(proposal)&.required_supports || Setting["votes_for_proposal_success"]
  end

  def next_goal_progress
    @next_goal_progress ||= (proposal.votes_for.size * 100) / next_goal_supports.to_i
  end
end
