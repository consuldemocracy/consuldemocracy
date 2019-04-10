require "rails_helper"
require "migrations/spending_proposal/ballots"

describe Migrations::SpendingProposal::Ballots do

  let!(:budget) { create(:budget, slug: "2016") }
  let!(:spending_proposal_ballot1) { create(:ballot) }
  let!(:spending_proposal_ballot2) { create(:ballot) }

  describe "#initialize" do

    it "initializes all spending proposal ballots" do
      migration = Migrations::SpendingProposal::Ballots.new

      expect(migration.spending_proposal_ballots.count).to eq(2)
      expect(migration.spending_proposal_ballots).to include(spending_proposal_ballot1)
      expect(migration.spending_proposal_ballots).to include(spending_proposal_ballot2)
    end

  end

  describe "#migrate_all" do

    context "ballot" do

      it "migrates all ballots" do
        Migrations::SpendingProposal::Ballots.new.migrate_all

        expect(Budget::Ballot.count).to eq(2)
      end

    end

    context "ballot lines" do

      let!(:group)   { create(:budget_group, budget: budget) }
      let!(:heading) { create(:budget_heading, group: group) }

      it "migrates ballot lines for all ballots" do
        spending_proposal = create(:spending_proposal, feasible: true)
        spending_proposal_ballot1.spending_proposals << spending_proposal
        spending_proposal_ballot2.spending_proposals << spending_proposal

        budget_investment = budget_invesment_for(spending_proposal, heading: heading)

        Migrations::SpendingProposal::Ballots.new.migrate_all

        expect(Budget::Ballot::Line.count).to eq(2)

        budget_investment_ballot1 = Budget::Ballot.first
        expect(budget_investment_ballot1.investments).to eq([budget_investment])

        budget_investment_ballot2 = Budget::Ballot.second
        expect(budget_investment_ballot2.investments).to eq([budget_investment])
      end

    end
  end
end
