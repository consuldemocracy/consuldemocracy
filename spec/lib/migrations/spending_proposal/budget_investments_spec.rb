require "rails_helper"
require "migrations/spending_proposal/budget_investments"

describe Migrations::SpendingProposal::BudgetInvestments do

  let!(:budget)            { create(:budget, slug: "2016") }

  let!(:spending_proposal1) { create(:spending_proposal) }
  let!(:spending_proposal2) { create(:spending_proposal) }

  let!(:budget_investment1) { create(:budget_investment,
                                     budget: budget,
                                     original_spending_proposal_id: spending_proposal1.id) }

  let!(:budget_investment2) { create(:budget_investment,
                                     budget: budget,
                                     original_spending_proposal_id: spending_proposal2.id) }

  describe "#initialize" do

    it "initializes all spending proposals" do
      migration = Migrations::SpendingProposal::BudgetInvestments.new

      expect(migration.spending_proposals.count).to eq(2)
      expect(migration.spending_proposals).to include(spending_proposal1)
      expect(migration.spending_proposals).to include(spending_proposal2)
    end

  end

  describe "#update_all" do

    it "updates all budget investments with their corresponding spending proposal attributes" do
      explanation1 = "This project is not feasible because it is too expensive"
      explanation2 = "This project is not feasible because it out of the governments jurisdiction"

      spending_proposal1.update(feasible_explanation: explanation1)
      spending_proposal2.update(feasible_explanation: explanation2)

      migration = Migrations::SpendingProposal::BudgetInvestments.new
      migration.update_all

      budget_investment1.reload
      budget_investment2.reload

      expect(budget_investment1.unfeasibility_explanation).to eq(explanation1)
      expect(budget_investment2.unfeasibility_explanation).to eq(explanation2)
    end
  end
end
