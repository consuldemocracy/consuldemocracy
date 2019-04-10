require "rails_helper"
require "migrations/spending_proposal/vote"

describe Migrations::SpendingProposal::Vote do

  describe "#create_budget_investment_votes" do

    it "creates a budget investment's vote for a corresponding spending proposal's vote" do
      spending_proposal = create(:spending_proposal)
      budget_investment = create(:budget_investment, original_spending_proposal_id: spending_proposal.id)

      spending_proposal_vote = create(:vote, votable: spending_proposal)

      Migrations::SpendingProposal::Vote.new.create_budget_investment_votes

      budget_investment_vote = budget_investment.votes_for.first

      expect(budget_investment.votes_for.count).to eq(1)
      expect(budget_investment_vote.voter).to eq(spending_proposal_vote.voter)
      expect(budget_investment_vote.votable).to eq(budget_investment)
      expect(budget_investment_vote.vote_flag).to eq(true)
    end

    it "creates budget investment's votes for all correspoding spending proposal's votes" do
      spending_proposal1 = create(:spending_proposal)
      spending_proposal2 = create(:spending_proposal)
      budget_investment1 = create(:budget_investment, original_spending_proposal_id: spending_proposal1.id)
      budget_investment2 = create(:budget_investment, original_spending_proposal_id: spending_proposal2.id)

      3.times { create(:vote, votable: spending_proposal1) }
      5.times { create(:vote, votable: spending_proposal2) }

      Migrations::SpendingProposal::Vote.new.create_budget_investment_votes

      expect(budget_investment1.votes_for.count).to eq(3)
      expect(budget_investment2.votes_for.count).to eq(5)
    end

    it "creates a budget investment's vote for a hidden user" do
      spending_proposal = create(:spending_proposal)
      budget_investment = create(:budget_investment, original_spending_proposal_id: spending_proposal.id)

      spending_proposal_vote = create(:vote, votable: spending_proposal)

      spending_proposal_vote.voter.hide

      Migrations::SpendingProposal::Vote.new.create_budget_investment_votes

      budget_investment_vote = budget_investment.votes_for.first

      expect(budget_investment.votes_for.count).to eq(1)
      expect(budget_investment_vote.voter_id).to eq(spending_proposal_vote.voter_id)
      expect(budget_investment_vote.votable).to eq(budget_investment)
      expect(budget_investment_vote.vote_flag).to eq(true)
    end

    it "verifies if user has already voted" do
      spending_proposal = create(:spending_proposal)
      budget_investment = create(:budget_investment, original_spending_proposal_id: spending_proposal.id)

      spending_proposal_vote = create(:vote, votable: spending_proposal)

      Migrations::SpendingProposal::Vote.new.create_budget_investment_votes
      Migrations::SpendingProposal::Vote.new.create_budget_investment_votes

      expect(budget_investment.votes_for.count).to eq(1)
    end

    it "verifies if hidden user has already voted" do
      spending_proposal = create(:spending_proposal)
      budget_investment = create(:budget_investment, original_spending_proposal_id: spending_proposal.id)

      spending_proposal_vote = create(:vote, votable: spending_proposal)
      spending_proposal_vote.voter.hide

      Migrations::SpendingProposal::Vote.new.create_budget_investment_votes
      Migrations::SpendingProposal::Vote.new.create_budget_investment_votes

      expect(budget_investment.votes_for.count).to eq(1)
    end

    it "gracefully handles missing corresponding budget investment" do
      spending_proposal = create(:spending_proposal)
      spending_proposal_vote = create(:vote, votable: spending_proposal)

      expect{ Migrations::SpendingProposal::Vote.new.create_budget_investment_votes }
      .not_to raise_error
    end

  end
end
