class Api::ProposalsController < ApplicationController
  skip_authorization_check

  def index
    filter = ResourceFilter.new(Proposal, params)
    @proposals = filter.collection

    respond_to do |format|
      format.json { render json: @proposals }
    end
  end
end
