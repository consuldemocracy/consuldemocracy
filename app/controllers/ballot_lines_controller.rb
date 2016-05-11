class BallotLinesController < ApplicationController
  include SpendingProposalsSearch

  before_action :authenticate_user!
  before_action :load_ballot
  load_and_authorize_resource :ballot_line, through: :ballot, find_by: :spending_proposal_id

  def create
    load_spending_proposal
    load_geozone

    if @ballot_line.save
      @ballot.set_geozone(@geozone)
      load_spending_proposals
    else
      render :new
    end
  end

  def destroy
    @ballot_line.destroy

    load_spending_proposals
    load_geozone

    @ballot.reset_geozone
  end

  private

    def ballot_line_params
      params.permit(:spending_proposal_id)
    end

    def load_ballot
      @ballot = Ballot.where(user: current_user).first_or_create
    end

    def load_spending_proposal
      @spending_proposal = @ballot_line.spending_proposal
    end

    def load_spending_proposals
      @spending_proposals = apply_filters_and_search(SpendingProposal).sort_by_random(params[:random_seed]).page(params[:page]).for_render
    end

    def load_geozone
      @geozone = @ballot_line.spending_proposal.geozone
    end

end
