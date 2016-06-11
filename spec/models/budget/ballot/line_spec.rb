require 'rails_helper'

describe "Budget::Ballot::Line" do

  let(:ballot_line) { build(:budget_ballot_line) }

  describe 'Validations' do

    it "should be valid" do
      expect(ballot_line).to be_valid
    end

    it "should be invalid if missing id from ballot|budget|group|heading|investment" do
      budget = create(:budget)
      group = create(:budget_group, budget: budget)
      heading = create(:budget_heading, group: group, price: 10000000)
      investment = create(:budget_investment, :feasible, price: 5000000, heading: heading)
      ballot = create(:budget_ballot, budget: budget)

      ballot_line = build(:budget_ballot_line, ballot: ballot, budget: budget, group: group, heading: heading, investment: investment)
      expect(ballot_line).to be_valid

      ballot_line = build(:budget_ballot_line, ballot: nil, budget: budget, group: group, heading: heading, investment: investment)
      expect(ballot_line).to_not be_valid

      ballot_line = build(:budget_ballot_line, ballot: ballot, budget: nil, group: group, heading: heading, investment: investment)
      expect(ballot_line).to_not be_valid

      ballot_line = build(:budget_ballot_line, ballot: ballot, budget: budget, group: nil, heading: heading, investment: investment)
      expect(ballot_line).to_not be_valid

      ballot_line = build(:budget_ballot_line, ballot: ballot, budget: budget, group: group, heading: nil, investment: investment)
      expect(ballot_line).to_not be_valid

      ballot_line = build(:budget_ballot_line, ballot: ballot, budget: budget, group: group, heading: heading, investment: nil)
      expect(ballot_line).to_not be_valid
    end

  end
end