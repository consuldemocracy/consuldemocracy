class BallotLinesController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_final_voting_allowed
  before_action :load_ballot
  before_action :load_spending_proposals
  load_and_authorize_resource :ballot_line, through: :ballot, find_by: :spending_proposal_id

  def create
    load_spending_proposal
    load_geozone

    if @ballot_line.save
      @ballot.set_geozone(@geozone)
      @current_user.update(representative_id: nil)
    else
      render :new
    end
  end

  def destroy
    load_spending_proposal
    load_spending_proposals
    load_geozone

    @ballot_line.destroy
    @ballot.reset_geozone
  end

  private

    def ensure_final_voting_allowed
      if Setting["feature.spending_proposal_features.phase3"].blank? ||
         Setting["feature.spending_proposal_features.final_voting_allowed"].blank?
        head(:forbidden)
      end
    end

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
      if params[:spending_proposals_ids].present?
        @spending_proposals = SpendingProposal.where(id: params[:spending_proposals_ids])
      end
    end

    def load_geozone
      @geozone = @ballot_line.spending_proposal.geozone
    end

end
