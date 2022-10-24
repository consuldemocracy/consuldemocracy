require "rails_helper"

describe Poll::Ballot do
  let(:budget) { create(:budget) }
  let(:group) { create(:budget_group, budget: budget) }
  let(:heading) { create(:budget_heading, group: group, price: 10000000) }
  let(:investment) { create(:budget_investment, :selected, price: 5000000, heading: heading) }
  let(:poll) { create(:poll, budget: budget) }
  let(:poll_ballot_sheet) { create(:poll_ballot_sheet, poll: poll) }
  let(:poll_ballot) { create(:poll_ballot, ballot_sheet: poll_ballot_sheet, external_id: 1, data: investment.id) }
  before { create(:budget_ballot, budget: budget, physical: true, poll_ballot: poll_ballot) }

  describe "#verify" do
    it "adds ballot lines until there are sufficiente funds" do
      investment2 = create(:budget_investment, :selected, price: 2000000, heading: heading)
      investment3 = create(:budget_investment, :selected, price: 2000000, heading: heading)
      investment4 = create(:budget_investment, :selected, price: 2000000, heading: heading)

      poll_ballot.update!(data: [investment.id, investment2.id, investment3.id, investment4.id].join(","))
      poll_ballot.verify

      expect(poll_ballot.ballot.lines.pluck(:investment_id)).to match_array [investment.id, investment2.id, investment3.id]
    end

    it "adds ballot lines if they are from valid headings" do
      other_heading = create(:budget_heading, group: group, price: 10000000)

      investment2 = create(:budget_investment, :selected, price: 2000000, heading: heading)
      investment3 = create(:budget_investment, :selected, price: 2000000, heading: heading)
      investment4 = create(:budget_investment, :selected, price: 2000000, heading: other_heading)

      poll_ballot.update!(data: [investment.id, investment2.id, investment3.id, investment4.id].join(","))
      poll_ballot.verify

      expect(poll_ballot.ballot.lines.pluck(:investment_id)).to match_array [investment.id, investment2.id, investment3.id]
    end

    it "adds ballot lines if they are from selectable" do
      investment2 = create(:budget_investment, :selected, price: 2000000, heading: heading)
      investment3 = create(:budget_investment, :selected, price: 2000000, heading: heading)
      investment4 = create(:budget_investment, price: 2000000, heading: heading)

      poll_ballot.update!(data: [investment.id, investment2.id, investment3.id, investment4.id].join(","))
      poll_ballot.verify

      expect(poll_ballot.ballot.lines.pluck(:investment_id)).to match_array [investment.id, investment2.id, investment3.id]
    end
  end

  describe "#add_investment" do
    describe "Money" do
      it "is not valid if insufficient funds" do
        investment.update!(price: heading.price + 1)
        expect(poll_ballot.add_investment(investment.id)).to be(false)
      end

      it "is valid if sufficient funds" do
        investment.update!(price: heading.price - 1)
        expect(poll_ballot.add_investment(investment.id)).to be(true)
      end
    end

    describe "Heading" do
      it "is not valid if investment heading is not valid" do
        expect(poll_ballot.add_investment(investment.id)).to be(true)

        other_heading = create(:budget_heading, group: group, price: 10000000)
        other_investment = create(:budget_investment, :selected, price: 1000000, heading: other_heading)

        expect(poll_ballot.add_investment(other_investment.id)).to be(false)
      end

      it "is valid if investment heading is valid" do
        expect(poll_ballot.add_investment(investment.id)).to be(true)

        other_investment = create(:budget_investment, :selected, price: 1000000, heading: heading)

        expect(poll_ballot.add_investment(other_investment.id)).to be(true)
      end
    end

    describe "Selectibility" do
      it "is not valid if investment is unselected" do
        investment.update!(selected: false)
        expect(poll_ballot.add_investment(investment.id)).to be(false)
      end

      it "is valid if investment is selected" do
        investment.update!(selected: true, price: 20000)
        expect(poll_ballot.add_investment(investment.id)).to be(true)
      end
    end

    describe "Budget" do
      it "is not valid if investment belongs to a different budget" do
        other_budget = create(:budget)
        investment.update!(budget: other_budget)
        expect(poll_ballot.add_investment(investment.id)).to be(nil)
      end

      it "is valid if investment belongs to the poll's budget" do
        expect(poll_ballot.add_investment(investment.id)).to be(true)
      end
    end

    describe "Already added" do
      it "is not valid if already exists" do
        poll_ballot.add_investment(investment.id)
        expect(poll_ballot.add_investment(investment.id)).to be(nil)
      end

      it "is valid if does not already exist" do
        expect(poll_ballot.add_investment(investment.id)).to be(true)
      end
    end
  end

  describe "#find_investment" do
    it "returns the investment if found" do
      expect(poll_ballot.find_investment(investment.id)).to eq(investment)
    end

    it "finds investments with trailing zeros" do
      expect(poll_ballot.find_investment("0#{investment.id}")).to eq(investment)
      expect(poll_ballot.find_investment("00#{investment.id}")).to eq(investment)
    end
  end
end
