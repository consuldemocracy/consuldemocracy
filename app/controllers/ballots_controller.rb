class BallotsController < ApplicationController
  before_action :load_ballot
  before_action :load_spending_proposal, only: [:add, :remove]
  before_action :authenticate_user!
  skip_authorization_check

  def add
    ballot_line = @ballot.ballot_lines.create(spending_proposal: @spending_proposal)
    @ballot.ballot_lines << ballot_line
  end

  def remove
    ballot_line = @ballot.ballot_lines.where(spending_proposal: @spending_proposal).first
    ballot_line.destroy
  end

  def show
    @ballot = current_user.ballot
  end

  private

    def load_ballot
      @ballot = Ballot.where(user: current_user).first_or_create
    end

    def load_spending_proposal
      @spending_proposal = SpendingProposal.find(params[:spending_proposal_id])
    end
end
