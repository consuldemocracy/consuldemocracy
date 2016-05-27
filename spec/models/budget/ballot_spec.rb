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
      inv3 = create(:budget_investment, :feasible, price: 25000)
      inv4 = create(:budget_investment, :feasible, price: 40000, heading: heading)

      ballot = create(:budget_ballot)
      ballot.investments << inv1
      ballot.investments << inv2
      ballot.investments << inv3

      expect(ballot.amount_spent(heading.id)).to eq 10000
      expect(ballot.amount_spent(nil)).to eq 25000

      ballot.investments << inv4

      expect(ballot.amount_spent(heading.id)).to eq 50000
    end
  end

  describe "#amount_available" do
    it "returns how much is left after taking some investments" do
      budget = create(:budget, price: 200000)
      heading = create(:budget_heading, budget: budget)
      inv1 = create(:budget_investment, :feasible, price: 10000, heading: heading)
      inv2 = create(:budget_investment, :feasible, price: 20000, heading: create(:budget_heading))
      inv3 = create(:budget_investment, :feasible, price: 25000)
      inv4 = create(:budget_investment, :feasible, price: 40000, heading: heading)

      inv1 = create(:budget_investment, :feasible, price: 10000)
      inv2 = create(:budget_investment, :feasible, price: 20000)

      ballot = create(:budget_ballot, budget: budget)
      ballot.investments << inv1
      ballot.investments << inv2

      expect(ballot.amount_available(heading)).to eq 1000000
      expect(ballot.amount_available(nil)).to eq 170000

      ballot.investments << inv3
      ballot.investments << inv4

      expect(ballot.amount_available(heading)).to eq 960000
      expect(ballot.amount_available(nil)).to eq 145000
    end
  end

end
