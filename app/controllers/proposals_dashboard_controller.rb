# frozen_string_literal: true

# Proposals dashboard
class ProposalsDashboardController < ApplicationController
  before_action :authenticate_user!

  helper_method :proposal, :proposed_actions, :resources, :proposal_dashboard_action
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

  def new_request
    authorize! :dashboard, proposal
    @proposal_executed_dashboard_action = ProposalExecutedDashboardAction.new
  end

  def create_request
    authorize! :dashboard, proposal

    source_params = proposal_executed_dashboard_action_params.merge(
      proposal: proposal, 
      proposal_dashboard_action: proposal_dashboard_action, 
      executed_at: Time.now
    )

    @proposal_executed_dashboard_action = ProposalExecutedDashboardAction.new(source_params)
    if @proposal_executed_dashboard_action.save
      AdministratorTask.create(source: @proposal_executed_dashboard_action)

      redirect_to proposal_dashboard_index_path(proposal.to_param), { flash: { info: t('.success') } }
    else
      render :new_request
    end
  end

  def stats
    authorize! :dashboard, proposal
  end

  def supports
    authorize! :dashboard, proposal
    render json: ProposalSupportsQuery.for(params)
  end

  private

  def proposal_executed_dashboard_action_params
    params.require(:proposal_executed_dashboard_action).permit(:comments)
  end

  def proposal_dashboard_action
    @proposal_dashboard_action ||= ProposalDashboardAction.find(params[:id])
  end

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
