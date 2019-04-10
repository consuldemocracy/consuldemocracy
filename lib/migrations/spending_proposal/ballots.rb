class Migrations::SpendingProposal::Ballots
  include Migrations::SpendingProposal::Common

  attr_accessor :spending_proposal_ballots

  def initialize
    @spending_proposal_ballots = load_ballots
  end

  def migrate_all
    spending_proposal_ballots.each do |spending_proposal_ballot|
      budget_investment_ballot = Migrations::SpendingProposal::Ballot.new(spending_proposal_ballot)
      budget_investment_ballot.migrate_ballot
    end
  end

  private

    def load_ballots
      ::Ballot.all
    end

end
