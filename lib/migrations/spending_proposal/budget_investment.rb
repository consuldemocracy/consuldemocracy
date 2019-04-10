class Migrations::SpendingProposal::BudgetInvestment
  include Migrations::SpendingProposal::Common

  attr_accessor :spending_proposal, :budget_investment

  def initialize(spending_proposal)
    @spending_proposal = spending_proposal
    @budget_investment = find_budget_investment(spending_proposal)
  end

  def update
    if updated?
      log(".")
    else
      log("\nError updating budget investment from spending proposal: #{spending_proposal.id}\n")
    end
  end

  private

    def updated?
      if budget_investment.blank?
        log("No budget investment found for #{spending_proposal.id}")
        return false
      end

      update_attributes && create_valuation_comments
    end

    def update_attributes
      budget_investment.update(budget_investment_attributes)
    end

    def budget_investment_attributes
      { unfeasibility_explanation: field_with_unfeasibility_explanation }
    end

    def field_with_unfeasibility_explanation
      if spending_proposal.unfeasible?
        spending_proposal.feasible_explanation.presence ||
        spending_proposal.price_explanation.presence ||
        spending_proposal.internal_comments
      else
        spending_proposal.feasible_explanation
      end
    end

    def create_valuation_comments
      return true if spending_proposal.internal_comments.blank?

      comment = new_valuation_comment
      if comment.save
        log(".")
        return true
      else
        log("Error creating comment for budget investment: #{budget_investment.id}\n")
        log(comment.errors.messages)
        return false
      end
    end

    def new_valuation_comment
      budget_investment.valuations.first_or_initialize(valuation_comment_attributes)
    end

    def valuation_comment_attributes
      {
        body: spending_proposal.internal_comments,
        user: spending_proposal_administrator
      }
    end

    def spending_proposal_administrator
      spending_proposal.administrator.try(&:user) || Administrator.first.user
    end

end
