require 'rails_helper'

describe Budget::Ballot do

  describe "#amount_spent" do
    it "returns the total amount spent in investments" do
      budget = create(:budget)
      group1 = create(:budget_group, budget: budget)
      group2 = create(:budget_group, budget: budget)
      heading1 = create(:budget_heading, group: group1, price: 100000)
      heading2 = create(:budget_heading, group: group2, price: 200000)
      inv1 = create(:budget_investment, :feasible, price: 10000, heading: heading1)
      inv2 = create(:budget_investment, :feasible, price: 20000, heading: heading2)

      ballot = create(:budget_ballot, budget: budget)
      ballot.add_investment inv1

      expect(ballot.total_amount_spent).to eq 10000

      ballot.add_investment inv2

      expect(ballot.total_amount_spent).to eq 30000
    end

    it "returns the amount spent on all investments assigned to a specific heading" do
      heading = create(:budget_heading)
      budget = heading.group.budget
      inv1 = create(:budget_investment, :feasible, price: 10000, heading: heading)
      inv2 = create(:budget_investment, :feasible, price: 20000, heading: create(:budget_heading, group: heading.group))
      inv3 = create(:budget_investment, :feasible, price: 40000, heading: heading)

      ballot = create(:budget_ballot, budget: budget)
      ballot.add_investment inv1
      ballot.add_investment inv2

      expect(ballot.amount_spent(heading.id)).to eq 10000

      ballot.add_investment inv3

      expect(ballot.amount_spent(heading.id)).to eq 50000
    end
  end

  describe "#amount_available" do
    it "returns how much is left after taking some investments" do
      budget = create(:budget)
      group = create(:budget_group, budget: budget)
      heading1 = create(:budget_heading, group: group, price: 1000)
      heading2 = create(:budget_heading, group: group, price: 300)
      inv1 = create(:budget_investment, :feasible, price: 100, heading: heading1)
      inv2 = create(:budget_investment, :feasible, price: 200, heading: heading2)
      inv3 = create(:budget_investment, :feasible, price: 400, heading: heading1)

      ballot = create(:budget_ballot, budget: budget)
      ballot.add_investment inv1
      ballot.add_investment inv2

      expect(ballot.amount_available(heading1)).to eq 900
      expect(ballot.amount_available(heading2)).to eq 100

      ballot.add_investment inv3

      expect(ballot.amount_available(heading1)).to eq 500
    end
  end

end
