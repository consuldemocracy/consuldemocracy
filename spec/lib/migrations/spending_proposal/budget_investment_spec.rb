require "rails_helper"
require "migrations/spending_proposal/budget_investment"

describe Migrations::SpendingProposal::BudgetInvestment do

  let!(:budget)            { create(:budget, slug: "2016") }

  let!(:spending_proposal) { create(:spending_proposal) }

  let!(:budget_investment) { create(:budget_investment,
                                     budget: budget,
                                     original_spending_proposal_id: spending_proposal.id) }

  describe "#initialize" do

    it "initializes the spending proposal and corresponding budget investment" do
      migration = Migrations::SpendingProposal::BudgetInvestment.new(spending_proposal)

      expect(migration.spending_proposal).to eq(spending_proposal)
      expect(migration.budget_investment).to eq(budget_investment)
    end

  end

  describe "#update" do

    it "updates the attribute unfeasibility_explanation" do
      explanation = "This project is not feasible because it is too expensive"
      spending_proposal.update(feasible_explanation: explanation)

      migration = Migrations::SpendingProposal::BudgetInvestment.new(spending_proposal)
      migration.update

      budget_investment.reload

      expect(budget_investment.unfeasibility_explanation).to eq(explanation)
    end

    it "uses the price explanation attribute if unfeasibility explanation is not present" do
      spending_proposal.feasible_explanation = ""
      spending_proposal.price_explanation = "price explanation saying it is too expensive"

      spending_proposal.feasible = false
      spending_proposal.valuation_finished = true

      spending_proposal.save(validate: false)

      migration = Migrations::SpendingProposal::BudgetInvestment.new(spending_proposal)
      migration.update

      budget_investment.reload
      expect(budget_investment.unfeasibility_explanation).to eq("price explanation saying it is too expensive")
    end

    it "uses the internal comments if unfeasibility explanation is not present" do
      spending_proposal.feasible_explanation = ""
      spending_proposal.internal_comments = "Internal comment with explanation"

      spending_proposal.feasible = false
      spending_proposal.valuation_finished = true
      spending_proposal.update(administrator: create(:administrator))

      spending_proposal.save(validate: false)

      migration = Migrations::SpendingProposal::BudgetInvestment.new(spending_proposal)
      migration.update

      budget_investment.reload
      expect(budget_investment.unfeasibility_explanation).to eq("Internal comment with explanation")
    end

    it "does not use other attributes if investment is feasible" do
      spending_proposal.feasible_explanation = ""
      spending_proposal.price_explanation = "price explanation saying it is too expensive"

      spending_proposal.feasible = true
      spending_proposal.save(validate: false)

      migration = Migrations::SpendingProposal::BudgetInvestment.new(spending_proposal)
      migration.update

      budget_investment.reload
      expect(budget_investment.unfeasibility_explanation).to eq("")
    end

    it "gracefully handles missing corresponding budget investment" do
      budget_investment.destroy

      expect{ migration = Migrations::SpendingProposal::BudgetInvestment.new(spending_proposal);
              migration.update }
      .not_to raise_error
    end

  end

  context "internal comments" do

    it "migrates internal_comments string to a comment object" do
      internal_comment = "This project will last 2 years"

      spending_proposal.update(internal_comments: internal_comment)
      spending_proposal.update(administrator: create(:administrator))

      migration = Migrations::SpendingProposal::BudgetInvestment.new(spending_proposal)
      migration.update

      comment = Comment.first
      expect(Comment.count).to eq(1)
      expect(comment.body).to eq(internal_comment)
      expect(comment.author).to eq(spending_proposal.administrator.user)
      expect(comment.commentable).to eq(budget_investment)
      expect(comment.valuation).to eq(true)
    end

    it "migrates internal comments with a body larger than the standard comment limit" do
      allow(Comment).to receive(:body_max_length).and_return(20)

      internal_comment = "This project will last 2 years"
      spending_proposal.update(internal_comments: internal_comment)
      spending_proposal.update(administrator: create(:administrator))

      migration = Migrations::SpendingProposal::BudgetInvestment.new(spending_proposal)
      migration.update

      comment = Comment.first
      expect(Comment.count).to eq(1)
      expect(comment.body).to eq(internal_comment)
      expect(comment.commentable).to eq(budget_investment)
      expect(comment.valuation).to eq(true)
    end

    it "does not create a comment if internal_comments is blank" do
      migration = Migrations::SpendingProposal::BudgetInvestment.new(spending_proposal)
      migration.update

      expect(Comment.count).to eq(0)
    end

    it "verifies if the comment already exists" do
      internal_comment = "This project will last 2 years"

      spending_proposal.update(internal_comments: internal_comment)
      spending_proposal.update(administrator: create(:administrator))

      Migrations::SpendingProposal::BudgetInvestment.new(spending_proposal).update
      Migrations::SpendingProposal::BudgetInvestment.new(spending_proposal).update

      expect(Comment.count).to eq(1)
    end

    it "assigns the first administrator if a spending proposal does not have one" do
      first_admin = create(:administrator).user
      internal_comment = "This project will last 2 years"

      spending_proposal.update(internal_comments: internal_comment)

      Migrations::SpendingProposal::BudgetInvestment.new(spending_proposal).update

      expect(Comment.first.author).to eq(first_admin)
    end

  end
end
