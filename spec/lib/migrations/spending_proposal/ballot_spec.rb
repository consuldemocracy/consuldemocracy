require "rails_helper"
require "migrations/spending_proposal/ballot"

describe Migrations::SpendingProposal::Ballot do

  let!(:budget) { create(:budget, slug: "2016") }
  let!(:spending_proposal_ballot) { create(:ballot) }

  describe "#initialize" do

    it "initializes the spending proposal ballot and corresponding budget investment ballot" do
      migration = Migrations::SpendingProposal::Ballot.new(spending_proposal_ballot)

      expect(migration.spending_proposal_ballot.class).to eq(Ballot)
      expect(migration.spending_proposal_ballot).to eq(spending_proposal_ballot)

      expect(migration.budget_investment_ballot.class).to eq(Budget::Ballot)
      expect(migration.budget_investment_ballot.budget).to eq(budget)
      expect(migration.budget_investment_ballot.user).to eq(spending_proposal_ballot.user)
    end

  end

  describe "#migrate_ballot" do

    context "ballot" do

      it "migrates a ballot" do
        Migrations::SpendingProposal::Ballot.new(spending_proposal_ballot).migrate_ballot

        expect(Budget::Ballot.count).to eq(1)

        budget_investment_ballot = Budget::Ballot.first
        expect(budget_investment_ballot.budget).to eq(budget)
        expect(budget_investment_ballot.user).to eq(spending_proposal_ballot.user)
      end

      it "migrates a ballot for hidden users" do
        spending_proposal_ballot.user.hide

        Migrations::SpendingProposal::Ballot.new(spending_proposal_ballot).migrate_ballot

        expect(Budget::Ballot.count).to eq(1)

        budget_investment_ballot = Budget::Ballot.first
        expect(budget_investment_ballot.budget).to eq(budget)
        expect(budget_investment_ballot.user_id).to eq(spending_proposal_ballot.user_id)
      end

      it "verifies if ballot has already been created" do
        Migrations::SpendingProposal::Ballot.new(spending_proposal_ballot).migrate_ballot
        Migrations::SpendingProposal::Ballot.new(spending_proposal_ballot).migrate_ballot

        expect(Budget::Ballot.count).to eq(1)
      end

    end

    context "ballot lines" do

      let!(:group)   { create(:budget_group, budget: budget) }
      let!(:heading) { create(:budget_heading, group: group) }

      it "migrates a single ballot line" do
        spending_proposal = create(:spending_proposal, feasible: true)
        spending_proposal_ballot.spending_proposals << spending_proposal

        budget_investment = budget_invesment_for(spending_proposal, heading: heading)

        Migrations::SpendingProposal::Ballot.new(spending_proposal_ballot).migrate_ballot

        budget_investment_ballot = Budget::Ballot.first
        expect(budget_investment_ballot.investments).to eq([budget_investment])
      end

      it "migrates multiple ballot lines" do
        spending_proposal1 = create(:spending_proposal, feasible: true)
        spending_proposal2 = create(:spending_proposal, feasible: true)
        spending_proposal3 = create(:spending_proposal, feasible: true)

        budget_investment1 = budget_invesment_for(spending_proposal1, heading: heading)
        budget_investment2 = budget_invesment_for(spending_proposal2, heading: heading)
        budget_investment3 = budget_invesment_for(spending_proposal3, heading: heading)

        spending_proposal_ballot.spending_proposals << spending_proposal1
        spending_proposal_ballot.spending_proposals << spending_proposal2

        Migrations::SpendingProposal::Ballot.new(spending_proposal_ballot).migrate_ballot

        budget_investment_ballot = Budget::Ballot.first

        expect(budget_investment_ballot.investments).to include(budget_investment1)
        expect(budget_investment_ballot.investments).to include(budget_investment2)
        expect(budget_investment_ballot.investments).not_to include(budget_investment3)
      end

      it "migrates ballot lines in all of a user's ballots" do
        user = create(:user)
        spending_proposal_ballot1 = create(:ballot, user: user)
        spending_proposal_ballot2 = create(:ballot, user: user)

        spending_proposal1 = create(:spending_proposal, feasible: true)
        spending_proposal2 = create(:spending_proposal, feasible: true)
        spending_proposal3 = create(:spending_proposal, feasible: true)

        budget_investment1 = budget_invesment_for(spending_proposal1, heading: heading)
        budget_investment2 = budget_invesment_for(spending_proposal2, heading: heading)
        budget_investment3 = budget_invesment_for(spending_proposal3, heading: heading)

        spending_proposal_ballot1.spending_proposals << spending_proposal1
        spending_proposal_ballot2.spending_proposals << spending_proposal2

        Migrations::SpendingProposal::Ballot.new(spending_proposal_ballot1).migrate_ballot
        Migrations::SpendingProposal::Ballot.new(spending_proposal_ballot2).migrate_ballot

        budget_investment_ballot = Budget::Ballot.first

        expect(budget_investment_ballot.investments).to include(budget_investment1)
        expect(budget_investment_ballot.investments).to include(budget_investment2)
        expect(budget_investment_ballot.investments).not_to include(budget_investment3)
      end

      it "verifies that the ballot line does not exist" do
        spending_proposal = create(:spending_proposal, feasible: true)
        spending_proposal_ballot.spending_proposals << spending_proposal

        budget_investment = budget_invesment_for(spending_proposal, heading: heading)

        Migrations::SpendingProposal::Ballot.new(spending_proposal_ballot).migrate_ballot
        Migrations::SpendingProposal::Ballot.new(spending_proposal_ballot).migrate_ballot

        budget_investment_ballot = Budget::Ballot.first
        expect(budget_investment_ballot.investments.count).to eq(1)
      end

      it "gracefully handles missing corresponding budget investment" do
        spending_proposal = create(:spending_proposal, feasible: true)
        spending_proposal_ballot.spending_proposals << spending_proposal

        expect{ Migrations::SpendingProposal::Ballot.new(spending_proposal_ballot).migrate_ballot }
        .not_to raise_error
      end

    end
  end
end
