require_dependency "budget"
require_dependency "budget/ballot"

class Migrations::SpendingProposal::Ballot
  include Migrations::SpendingProposal::Common

  attr_accessor :spending_proposal_ballot, :budget_investment_ballot, :represented_user

  def initialize(spending_proposal_ballot, represented_user=nil)
    @represented_user = represented_user
    @spending_proposal_ballot = spending_proposal_ballot
    @budget_investment_ballot = find_or_initialize_budget_investment_ballot
  end

  def migrate_ballot
    return if user_already_voted?

    if budget_investment_ballot.save
      log(".")
      migrate_ballot_lines
    else
      log("\nError creating budget investment ballot from spending proposal ballot #{spending_proposal_ballot.id}\n")
    end
  end

  def migrate_ballot_lines
    spending_proposal_ballot.spending_proposals.each do |spending_proposal|
      budget_investment = find_budget_investment(spending_proposal)

      if budget_investment.blank?
        log("Budget investment not found for spending proposal #{spending_proposal.id}")
        next
      end

      ballot_line = find_or_initialize_ballot_line(budget_investment)
      if ballot_line_saved?(ballot_line)
        log(".")
      else
        log("Error adding spending proposal: #{spending_proposal.id} to ballot: #{budget_investment_ballot.id}\n")
        log(ballot_line.errors.messages)
      end
    end
  end

  private

    def find_or_initialize_budget_investment_ballot
      Budget::Ballot.find_or_initialize_by(budget_investment_ballot_attributes)
    end

    def find_or_initialize_ballot_line(investment)
      return nil if investment.blank?

      attributes = { ballot: budget_investment_ballot, investment: investment }
      budget_investment_ballot.lines.where(attributes).first_or_initialize
    end

    def user_already_voted?
      budget_investment_ballot.ballot_lines_count > 0 && represented_user
    end

    def ballot_line_saved?(ballot_line)
      return true if ballot_line_exists?(ballot_line)

      ballot_line.set_denormalized_ids
      ballot_line.save(validate: false)
    end

    def ballot_line_exists?(ballot_line)
      budget_investment_ballot.investments.include?(ballot_line.investment)
    end

    def budget_investment_ballot_attributes
      {
        budget_id: budget.id,
        user_id: user_id
      }
    end

    def user_id
      represented_user.try(:id) || spending_proposal_ballot.user_id
    end

end
