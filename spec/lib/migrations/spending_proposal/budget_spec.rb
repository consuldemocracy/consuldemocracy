require "rails_helper"
require "migrations/spending_proposal/budget"

describe Migrations::SpendingProposal::Budget do

  let!(:budget) { create(:budget, slug: "2016") }
  let(:migration) { Migrations::SpendingProposal::Budget.new }

  describe "#initialize" do

    it "initializes the budget to be migrated" do
      expect(migration.budget).to eq(budget)
    end

  end

  describe "#setup" do

    let!(:city_group)   { create(:budget_group, budget: budget) }
    let!(:city_heading) { create(:budget_heading, group: city_group, name: "Toda la ciudad") }

    let!(:district_group)    { create(:budget_group, budget: budget) }
    let!(:district_heading1) { create(:budget_heading, group: district_group, name: "Arganzuela") }
    let!(:district_heading2) { create(:budget_heading, group: district_group, name: "Barajas") }

    context "heading price" do

      it "updates the city heading's price" do
        migration.setup

        city_heading.reload
        expect(city_heading.price).to eq(24000000)
      end

      it "updates the district headings' price" do
        migration.setup

        district_heading1.reload
        district_heading2.reload
        expect(district_heading1.price).to eq(1556169)
        expect(district_heading2.price).to eq(433589)
      end
    end

    context "heading population" do

      it "updates the city heading's population" do
        migration.setup

        city_heading.reload
        expect(city_heading.population).to eq(2706401)
      end

      it "updates the district headings' population" do
        migration.setup

        district_heading1.reload
        district_heading2.reload
        expect(district_heading1.population).to eq(131429)
        expect(district_heading2.population).to eq(37725)
      end
    end

    it "migrates budget investments" do
      spending_proposal1 = create(:spending_proposal)
      spending_proposal2 = create(:spending_proposal)

      migration.setup

      expect(Budget::Investment.count).to eq(2)

      budget_investment_references = Budget::Investment.pluck(:original_spending_proposal_id)
      expect(budget_investment_references).to include(spending_proposal1.id)
      expect(budget_investment_references).to include(spending_proposal2.id)
    end
  end

  describe "migrate" do

    context "Migrate budget investments" do

      it "marks feasible and valuation finished investments as selected" do
        spending_proposal1 = create(:spending_proposal, :feasible, :finished)
        spending_proposal2 = create(:spending_proposal, :feasible, :finished)
        spending_proposal3 = create(:spending_proposal, :feasible, :unfinished)
        spending_proposal4 = create(:spending_proposal, :unfeasible, :finished)

        budget_investment1 = create(:budget_investment, budget: budget, spending_proposal: spending_proposal1)
        budget_investment2 = create(:budget_investment, budget: budget, spending_proposal: spending_proposal2)
        budget_investment3 = create(:budget_investment, budget: budget, spending_proposal: spending_proposal3)
        budget_investment4 = create(:budget_investment, budget: budget, spending_proposal: spending_proposal4)

        migration.migrate_data

        budget_investment1.reload
        budget_investment2.reload
        budget_investment3.reload
        budget_investment4.reload

        expect(budget_investment1.selected).to eq(true)
        expect(budget_investment2.selected).to eq(true)
        expect(budget_investment3.selected).to eq(false)
        expect(budget_investment4.selected).to eq(false)
      end

    end

    it "migrates votes" do
      spending_proposal = create(:spending_proposal)
      spending_proposal_vote1 = create(:vote, votable: spending_proposal)
      spending_proposal_vote2 = create(:vote, votable: spending_proposal)

      investment = budget_invesment_for(spending_proposal)

      migration.migrate_data

      expect(investment.votes_for.count).to eq(2)
    end

    it "migrates ballots" do
      spending_proposal = create(:spending_proposal)
      spending_proposal_ballot_line1 = create(:ballot_line, spending_proposal: spending_proposal)
      spending_proposal_ballot_line2 = create(:ballot_line, spending_proposal: spending_proposal)

      investment = budget_invesment_for(spending_proposal)

      migration.migrate_data

      expect(Budget::Ballot.count).to eq(2)

      budget_investment_ballot1 = Budget::Ballot.first
      expect(budget_investment_ballot1.investments).to eq([investment])

      budget_investment_ballot2 = Budget::Ballot.second
      expect(budget_investment_ballot2.investments).to eq([investment])
    end
  end

  describe "#expire_caches" do

    let!(:group)   { create(:budget_group, budget: budget) }
    let!(:heading) { create(:budget_heading, group: group, price: 99999999) }

    it "Updates cached votes" do
      investment = create(:budget_investment, :selected, heading: heading)

      create(:vote, votable: investment)
      create(:vote, votable: investment)

      investment.update(cached_votes_up: 3)

      investment.reload
      expect(investment.cached_votes_up).to eq(3)

      migration.expire_caches

      investment.reload
      expect(investment.cached_votes_up).to eq(2)
    end

    it "Updates cached ballot lines" do
      investment = create(:budget_investment, :selected, heading: heading)

      ballot1 = create(:budget_ballot, budget: budget)
      ballot2 = create(:budget_ballot, budget: budget)

      create(:budget_ballot_line, ballot: ballot1, investment: investment)
      create(:budget_ballot_line, ballot: ballot2, investment: investment)

      investment.update(ballot_lines_count: 3)

      investment.reload
      expect(investment.ballot_lines_count).to eq(3)

      migration.expire_caches

      investment.reload
      expect(investment.ballot_lines_count).to eq(2)
    end

    it "Calculates winners" do
      ballot = create(:budget_ballot, budget: budget)

      investment1 = create(:budget_investment, :selected, heading: heading)
      investment2 = create(:budget_investment, :selected, heading: heading)
      investment3 = create(:budget_investment, :selected, heading: heading)

      create(:budget_ballot_line, ballot: ballot, investment: investment1)
      create(:budget_ballot_line, ballot: ballot, investment: investment2)

      results = Budget::Result.new(budget, heading)
      expect(results.winners.count).to eq(0)

      migration.expire_caches

      expect(results.winners.count).to eq(3)
    end
  end

  describe "#destroy_associated" do

    it "destroys associated spending proposal records" do
      investment = create(:budget_investment)
      spending_proposal = create(:spending_proposal)

      investment_vote = create(:vote, votable: investment)
      spending_proposal_vote = create(:vote, votable: spending_proposal)

      migration = Migrations::SpendingProposal::BudgetInvestments.new
      migration.destroy_associated

      expect(Vote.count).to eq(1)
      expect(Vote.first).to eq(investment_vote)
    end

  end
end
