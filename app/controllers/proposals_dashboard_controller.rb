# frozen_string_literal: true

# Proposals dashboard
class ProposalsDashboardController < ApplicationController
  before_action :authenticate_user!

  helper_method :proposal
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

  private

  def proposal
    @proposal ||= Proposal.find(params[:proposal_id])
  end
end
