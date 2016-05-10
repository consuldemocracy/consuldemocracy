class BallotLinesController < ApplicationController
  before_action :authenticate_user!
  before_action :load_ballot,  only: [:create, :destroy]

  skip_authorization_check

  def create
    @ballot_line = @ballot.ballot_lines.new(ballot_line_params)
    load_spending_proposal
    load_geozone

    if @ballot_line.save
      @ballot.set_geozone(@geozone)
    else
      render :new
    end
  end

  def destroy
    @ballot_line = BallotLine.where(spending_proposal_id: params[:id]).first
    @ballot_line.destroy

    load_spending_proposal
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

    def load_geozone
      @geozone = @ballot_line.spending_proposal.geozone
    end

end
