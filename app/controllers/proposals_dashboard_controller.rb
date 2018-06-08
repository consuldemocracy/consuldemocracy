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

  private

  def proposal
    @proposal ||= Proposal.find(params[:proposal_id])
  end
end
