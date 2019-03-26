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

  describe "#destroy_associated" do

    it "destroys spending proposals votes" do
      investment = create(:budget_investment)
      spending_proposal = create(:spending_proposal)

      investment_vote = create(:vote, votable: investment)
      spending_proposal_vote = create(:vote, votable: spending_proposal)

      migration = Migrations::SpendingProposal::BudgetInvestments.new
      migration.destroy_associated

      expect(Vote.count).to eq(1)
      expect(Vote.first).to eq(investment_vote)
    end

    it "destroys spending proposals taggings" do
      investment = create(:budget_investment)
      spending_proposal = create(:spending_proposal)

      health_tag = create(:tag, name: "Health")
      investment_tagging = create(:tagging, taggable: investment, tag: health_tag)
      spending_proposal_tagging = create(:tagging, taggable: spending_proposal, tag: health_tag)

      migration = Migrations::SpendingProposal::BudgetInvestments.new
      migration.destroy_associated

      expect(ActsAsTaggableOn::Tagging.count).to eq(1)
      expect(ActsAsTaggableOn::Tagging.first).to eq(investment_tagging)

      expect(Tag.count).to eq(1)
      expect(Tag.first).to eq(health_tag)
    end
  end
end
