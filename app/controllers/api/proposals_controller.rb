class Api::ProposalsController < ApplicationController
  skip_authorization_check

  def index
    filter = ProposalFilter.new(params)
    @proposals = filter.collection

    respond_to do |format|
      format.json { render json: @proposals }
    end
  end
end
