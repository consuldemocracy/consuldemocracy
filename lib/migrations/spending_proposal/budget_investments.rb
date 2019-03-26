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

  def destroy_associated
    if spending_proposals.any?
      Vote.where(votable: spending_proposals).destroy_all
      ActsAsTaggableOn::Tagging.where(taggable: spending_proposals).destroy_all
    end
  end

  private

    def load_spending_proposals
      ::SpendingProposal.all
    end

end
