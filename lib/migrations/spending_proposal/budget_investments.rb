class Migrations::SpendingProposal::BudgetInvestments
  include Migrations::SpendingProposal::Common

  attr_accessor :spending_proposals

  def initialize
    @spending_proposals = load_spending_proposals
  end

  def update_all
    spending_proposals.each do |spending_proposal|
      budget_investment = Migrations::SpendingProposal::BudgetInvestment.new(spending_proposal)
      budget_investment.update
    end
  end

  private

    def load_spending_proposals
      ::SpendingProposal.all
    end

end
