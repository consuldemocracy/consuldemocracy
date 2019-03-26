require "rails_helper"

describe Budget::Ballot::Line do

  let(:budget){ create(:budget) }
  let(:group){ create(:budget_group, budget: budget) }
  let(:heading){ create(:budget_heading, group: group, price: 10000000) }
  let(:investment){ create(:budget_investment, :selected, price: 5000000, heading: heading) }
  let(:ballot) { create(:budget_ballot, budget: budget) }
  let(:ballot_line) { build(:budget_ballot_line, ballot: ballot, investment: investment) }

  describe "Validations" do

    it "is valid and automatically denormallyze budget, group and heading when validated" do
      expect(ballot_line).to be_valid
      expect(ballot_line.budget).to eq(budget)
      expect(ballot_line.group).to eq(group)
      expect(ballot_line.heading).to eq(heading)
    end

    describe "Money" do
      it "is not valid if insufficient funds" do
        investment.update(price: heading.price + 1)
        expect(ballot_line).not_to be_valid
      end

      it "is valid if sufficient funds" do
        investment.update(price: heading.price - 1)
        expect(ballot_line).to be_valid
      end
    end

    describe "Selectibility" do
      it "is not valid if investment is unselected" do
        investment.update(selected: false)
        expect(ballot_line).not_to be_valid
      end

      it "is valid if investment is selected" do
        investment.update(selected: true, price: 20000)
        expect(ballot_line).to be_valid
      end
    end

  end

  describe "scopes" do

    describe "by_investment" do

      it "returns ballot lines for an investment" do
        investment1 = create(:budget_investment, :selected, heading: heading)
        investment2 = create(:budget_investment, :selected, heading: heading)

        ballot1 = create(:budget_ballot, budget: budget)
        ballot2 = create(:budget_ballot, budget: budget)
        ballot3 = create(:budget_ballot, budget: budget)

        ballot_line1 = create(:budget_ballot_line, ballot: ballot1, investment: investment1)
        ballot_line2 = create(:budget_ballot_line, ballot: ballot2, investment: investment1)
        ballot_line3 = create(:budget_ballot_line, ballot: ballot3, investment: investment2)

        ballot_lines_by_investment = described_class.by_investment(investment1.id)

        expect(ballot_lines_by_investment).to include ballot_line1
        expect(ballot_lines_by_investment).to include ballot_line2
        expect(ballot_lines_by_investment).not_to include ballot_line3
      end

    end
  end
end
