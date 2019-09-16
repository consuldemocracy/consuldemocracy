require "rails_helper"

describe BallotsHelper do

  describe "#remaining_votes" do
    let(:budget) { create(:budget) }
    let(:group) { create(:budget_group, budget: budget) }
    let(:heading) { create(:budget_heading, group: group, max_votes: 5) }
    let(:ballot) { create(:budget_ballot, budget: budget) }
    let(:investment) { create(:budget_investment, :selected, heading: heading) }

    before do
      create(:budget_ballot_line, ballot: ballot, investment: investment)
    end

    it "Knapsack remaining votes" do
      expect(remaining_votes(ballot, group)).to eq("€999,990")
    end

    it "Approval remaining votes" do
      budget.update(voting_style: "approval")
      expect(remaining_votes(ballot, group)).to eq(4)
    end

  end

end
