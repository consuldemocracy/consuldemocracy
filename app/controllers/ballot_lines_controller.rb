class BallotLinesController < ApplicationController
  before_action :authenticate_user!
  before_action :load_ballot
  before_action :load_spending_proposals
  load_and_authorize_resource :ballot_line, through: :ballot, find_by: :spending_proposal_id

  def create
    load_spending_proposal
    load_geozone

    if @ballot_line.save
      @ballot.set_geozone(@geozone)
      @current_user.update(representative_id: nil)
      if request.get?
        redirect_to @spending_proposal, notice: t('spending_proposals.notice.voted')
      end
    else
      if request.get?
        redirect_to @spending_proposal, notice: t('spending_proposals.notice.could_not_vote')
      else
        render :new
      end
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
