class Migrations::SpendingProposal::Vote
  include Migrations::SpendingProposal::Common

  def create_budget_investment_votes
    spending_proposal_votes.each do |vote|
      create_budget_invesment_vote(vote)
    end
  end

  private

    def spending_proposal_votes
      ::Vote.where(votable: SpendingProposal.all)
    end

    def create_budget_invesment_vote(vote)
      budget_investment = find_budget_investment(vote.votable)
      return false unless budget_investment

      if vote.voter
        budget_investment.vote_by(voter: vote.voter, vote: "yes")
        log(".")
      elsif vote_with_hidden_user(vote.voter_id, budget_investment)
        log(".")
      else
        log("\nError creating budget investment vote from spending proposal vote: #{vote.id}\n")
      end
    end

    def vote_with_hidden_user(voter_id, budget_investment)
      vote_attributes = {
        voter_id: voter_id,
        votable: budget_investment,
        vote_flag: true
      }

      vote = Vote.where(vote_attributes).first_or_create
      vote.save(validate: false)
    end

end
