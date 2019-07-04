require "rails_helper"

describe Budget::Result do

  describe "calculate_winners" do
    let(:budget) { create(:budget) }
    let(:group) { create(:budget_group, budget: budget) }
    let(:heading) { create(:budget_heading, group: group, price: 1000) }

    context "When there is no winners" do
      it "calculates the correct winner set" do
        investment1 = create(:budget_investment, :selected, heading: heading, price: 200, ballot_lines_count: 900, winner: false)
        investment2 = create(:budget_investment, :selected, heading: heading, price: 300, ballot_lines_count: 800, winner: false)
        investment3 = create(:budget_investment, :incompatible, heading: heading, price: 500, ballot_lines_count: 700, winner: false)
        investment4 = create(:budget_investment, :selected, heading: heading, price: 500, ballot_lines_count: 600, winner: false)
        investment5 = create(:budget_investment, :selected, heading: heading, price: 100, ballot_lines_count: 500, winner: false)

        described_class.new(budget, heading).calculate_winners

        expect(heading.investments.winners.pluck(:id)).to match_array([investment1.id, investment2.id, investment4.id])
      end
    end

    context "When there are winners" do
      it "removes winners and recalculates" do
        investment1 = create(:budget_investment, :winner, heading: heading, price: 200, ballot_lines_count: 900)
        investment2 = create(:budget_investment, :winner, heading: heading, price: 300, ballot_lines_count: 800)
        investment3 = create(:budget_investment, :incompatible, heading: heading, price: 500, ballot_lines_count: 700, winner: true)
        investment4 = create(:budget_investment, :winner, heading: heading, price: 500, ballot_lines_count: 600)
        investment5 = create(:budget_investment, :winner, heading: heading, price: 100, ballot_lines_count: 500)

        described_class.new(budget, heading).calculate_winners

        expect(heading.investments.winners.pluck(:id)).to match_array([investment1.id, investment2.id, investment4.id])
      end
    end

    context "When a winner is flagged as incompatible" do
      it "recalculates winners leaving it out" do
        investment1 = create(:budget_investment, :winner, heading: heading, price: 200, ballot_lines_count: 900)
        investment2 = create(:budget_investment, :winner, heading: heading, price: 300, ballot_lines_count: 800)
        investment3 = create(:budget_investment, :winner, heading: heading, price: 500, ballot_lines_count: 700)
        investment4 = create(:budget_investment, :winner, heading: heading, price: 500, ballot_lines_count: 600)
        investment5 = create(:budget_investment, :winner, heading: heading, price: 100, ballot_lines_count: 500)

        investment3.incompatible = true
        investment3.save

        expect(heading.investments.winners.pluck(:id)).to match_array([investment1.id, investment2.id, investment4.id])
      end
    end

    context "When an incompatible is flagged as compatible again" do
      it "recalculates winners taking it in consideration" do
        investment1 = create(:budget_investment, :winner, heading: heading, price: 200, ballot_lines_count: 900)
        investment2 = create(:budget_investment, :winner, heading: heading, price: 300, ballot_lines_count: 800)
        investment3 = create(:budget_investment, :incompatible, heading: heading, price: 500, ballot_lines_count: 700)
        investment4 = create(:budget_investment, :winner, heading: heading, price: 500, ballot_lines_count: 600)
        investment5 = create(:budget_investment, :winner, heading: heading, price: 100, ballot_lines_count: 500)

        investment3.incompatible = false
        investment3.save

        expect(heading.investments.winners.pluck(:id)).to match_array([investment1.id, investment2.id, investment3.id])
      end
    end
  end
end
