require 'rails_helper'

describe Budget::Ballot do

  describe "validations" do

    it "should be valid" do
      budget = create(:budget)
      ballot = create(:budget_ballot, budget: budget)

      expect(ballot).to be_valid
    end

    it "should not be valid with the same investment twice" do
      budget = create(:budget)
      group  = create(:budget_group, budget: budget)
      heading = create(:budget_heading, group: group)
      investment = create(:budget_investment, :selected, heading: heading)

      ballot = create(:budget_ballot, budget: budget)
      ballot.investments << investment

      expect { ballot.investments << investment }.to raise_error(ActiveRecord::RecordNotUnique)
    end

  end

  describe "#amount_spent" do
    it "returns the total amount spent in investments" do
      budget = create(:budget)

      group1 = create(:budget_group, budget: budget)
      group2 = create(:budget_group, budget: budget)

      heading1 = create(:budget_heading, group: group1, price: 100000)
      heading2 = create(:budget_heading, group: group2, price: 200000)

      inv1 = create(:budget_investment, :selected, price: 10000, heading: heading1)
      inv2 = create(:budget_investment, :selected, price: 20000, heading: heading2)

      ballot = create(:budget_ballot, budget: budget)
      ballot.investments << inv1

      expect(ballot.total_amount_spent).to eq 10000

      ballot.investments << inv2

      expect(ballot.total_amount_spent).to eq 30000
    end

    it "returns the amount spent on all investments assigned to a specific heading" do
      budget = create(:budget)

      group1 = create(:budget_group, budget: budget)
      group2 = create(:budget_group, budget: budget)

      heading1 = create(:budget_heading, group: group1, price: 100000)
      heading2 = create(:budget_heading, group: group2, price: 200000)

      inv1 = create(:budget_investment, :selected, price: 10000, heading: heading1)
      inv2 = create(:budget_investment, :selected, price: 20000, heading: heading2)
      inv3 = create(:budget_investment, :selected, price: 40000, heading: heading1)

      ballot = create(:budget_ballot, budget: budget)
      ballot.investments << inv1 << inv2

      expect(ballot.amount_spent(heading1)).to eq 10000
      expect(ballot.amount_spent(heading2)).to eq 20000

      ballot.investments << inv3

      expect(ballot.amount_spent(heading1)).to eq 50000
      expect(ballot.amount_spent(heading2)).to eq 20000
    end
  end

  describe "#amount_available" do
    it "returns how much is left after taking some investments" do
      budget = create(:budget)

      group1 = create(:budget_group, budget: budget)
      group2 = create(:budget_group, budget: budget)

      heading1 = create(:budget_heading, group: group1, price: 1000)
      heading2 = create(:budget_heading, group: group2, price: 300)

      inv1 = create(:budget_investment, :selected, price: 100, heading: heading1)
      inv2 = create(:budget_investment, :selected, price: 200, heading: heading2)
      inv3 = create(:budget_investment, :selected, price: 400, heading: heading1)

      ballot = create(:budget_ballot, budget: budget)
      ballot.investments << inv1 << inv2

      expect(ballot.amount_available(heading1)).to eq 900
      expect(ballot.amount_available(heading2)).to eq 100

      ballot.investments << inv3

      expect(ballot.amount_available(heading1)).to eq 500
    end
  end

  describe "#heading_for_group" do

    it "returns the heading with balloted investments for a group" do
      budget = create(:budget)
      group = create(:budget_group, budget: budget)

      heading1 = create(:budget_heading, group: group)
      heading2 = create(:budget_heading, group: group)

      inv1 = create(:budget_investment, :selected, heading: heading1)
      inv2 = create(:budget_investment, :selected, heading: heading2)

      ballot = create(:budget_ballot, budget: budget)
      ballot.investments << inv2

      expect(ballot.heading_for_group(group)).to eq heading2
    end

    it "returns nil if there are no headings with balloted investments in a group" do
      budget = create(:budget)
      group = create(:budget_group, budget: budget)

      heading1 = create(:budget_heading, group: group)
      heading2 = create(:budget_heading, group: group)

      ballot = create(:budget_ballot, budget: budget)

      expect(ballot.heading_for_group(group)).to eq nil
    end

  end

end
