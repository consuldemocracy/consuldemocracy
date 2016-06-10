require 'rails_helper'

describe Budget::Ballot do

  describe "#amount_spent" do
    it "returns the total amount spent in investments" do
      inv1 = create(:budget_investment, :feasible, price: 10000)
      inv2 = create(:budget_investment, :feasible, price: 20000)

      ballot = create(:budget_ballot)
      ballot.investments << inv1

      expect(ballot.total_amount_spent).to eq 10000

      ballot.investments << inv2

      expect(ballot.total_amount_spent).to eq 30000
    end

    it "returns the amount spent on all investments assigned to a specific heading" do
      heading = create(:budget_heading)
      inv1 = create(:budget_investment, :feasible, price: 10000, heading: heading)
      inv2 = create(:budget_investment, :feasible, price: 20000, heading: create(:budget_heading))
      inv3 = create(:budget_investment, :feasible, price: 40000, heading: heading)

      ballot = create(:budget_ballot)
      ballot.investments << inv1
      ballot.investments << inv2

      expect(ballot.amount_spent(heading.id)).to eq 10000

      ballot.investments << inv3

      expect(ballot.amount_spent(heading.id)).to eq 50000
    end
  end

  describe "#amount_available" do
    it "returns how much is left after taking some investments" do
      budget = create(:budget)
      group = create(:budget_group, budget: budget)
      heading = create(:budget_heading, group: group, price: 1000)
      inv1 = create(:budget_investment, :feasible, price: 100, heading: heading)
      inv2 = create(:budget_investment, :feasible, price: 200, heading: create(:budget_heading))
      inv3 = create(:budget_investment, :feasible, price: 400, heading: heading)

      ballot = create(:budget_ballot, budget: budget)
      ballot.investments << inv1
      ballot.investments << inv2

      expect(ballot.amount_available(heading)).to eq 900

      ballot.investments << inv3

      expect(ballot.amount_available(heading)).to eq 500
    end
  end

end
