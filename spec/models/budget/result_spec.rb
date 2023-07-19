require "rails_helper"

describe Budget::Result do
  describe "calculate_winners" do
    let(:budget) { create(:budget) }
    let(:heading) { create(:budget_heading, budget: budget, price: 1000) }

    context "When there are no winners" do
      it "assigns investments ordered by ballot lines until budget is met" do
        create(:budget_investment, :selected, heading: heading, price: 100, ballot_lines_count: 50)
        create(:budget_investment, :selected, heading: heading, price: 300, ballot_lines_count: 80)
        create(:budget_investment, :selected, heading: heading, price: 200, ballot_lines_count: 90)
        create(:budget_investment, :selected, heading: heading, price: 500, ballot_lines_count: 60)

        Budget::Result.new(budget, heading).calculate_winners

        expect(heading.investments.winners.pluck(:ballot_lines_count)).to match_array([90, 80, 60])
      end

      it "selects cheaper investments when running out of budget" do
        create(:budget_investment, :selected, heading: heading, price: 800, ballot_lines_count: 90)
        create(:budget_investment, :selected, heading: heading, price: 300, ballot_lines_count: 80)
        create(:budget_investment, :selected, heading: heading, price: 200, ballot_lines_count: 60)

        Budget::Result.new(budget, heading).calculate_winners

        expect(heading.investments.winners.pluck(:ballot_lines_count)).to match_array([90, 60])
      end

      it "excludes incompatible investments" do
        create(:budget_investment, :selected, heading: heading, price: 200, ballot_lines_count: 90)
        create(:budget_investment, :selected, heading: heading, price: 300, ballot_lines_count: 80)
        create(:budget_investment, :incompatible, heading: heading, price: 500, ballot_lines_count: 70)
        create(:budget_investment, :selected, heading: heading, price: 500, ballot_lines_count: 60)
        create(:budget_investment, :selected, heading: heading, price: 100, ballot_lines_count: 50)

        Budget::Result.new(budget, heading).calculate_winners

        expect(heading.investments.winners.pluck(:ballot_lines_count)).to match_array([90, 80, 60])
      end
    end

    context "When there are winners" do
      it "removes winners and recalculates" do
        create(:budget_investment, :selected, heading: heading, price: 200, ballot_lines_count: 90)
        create(:budget_investment, :winner, heading: heading, price: 300, ballot_lines_count: 80)
        create(:budget_investment, :winner, :incompatible, heading: heading, price: 500, ballot_lines_count: 70)
        create(:budget_investment, :winner, heading: heading, price: 500, ballot_lines_count: 60)
        create(:budget_investment, :winner, heading: heading, price: 100, ballot_lines_count: 50)

        Budget::Result.new(budget, heading).calculate_winners

        expect(heading.investments.winners.pluck(:ballot_lines_count)).to match_array([90, 80, 60])
      end
    end

    context "When a winner is flagged as incompatible" do
      it "recalculates winners leaving it out" do
        wrong_win = create(:budget_investment, :winner, heading: heading, price: 200, ballot_lines_count: 90)

        create(:budget_investment, :winner, heading: heading, price: 300, ballot_lines_count: 80)
        create(:budget_investment, :winner, heading: heading, price: 500, ballot_lines_count: 70)
        create(:budget_investment, :winner, heading: heading, price: 200, ballot_lines_count: 60)
        create(:budget_investment, :winner, heading: heading, price: 100, ballot_lines_count: 50)

        wrong_win.update!(incompatible: true)

        expect(heading.investments.winners.pluck(:ballot_lines_count)).to match_array([80, 70, 60])
      end
    end

    context "When an incompatible is flagged as compatible again" do
      it "recalculates winners taking it in consideration" do
        miss = create(:budget_investment, :incompatible, heading: heading, price: 200, ballot_lines_count: 90)

        create(:budget_investment, :winner, heading: heading, price: 300, ballot_lines_count: 80)
        create(:budget_investment, :winner, heading: heading, price: 500, ballot_lines_count: 70)
        create(:budget_investment, :winner, heading: heading, price: 200, ballot_lines_count: 60)
        create(:budget_investment, :winner, heading: heading, price: 100, ballot_lines_count: 50)

        miss.update!(incompatible: false)

        expect(heading.investments.winners.pluck(:ballot_lines_count)).to match_array([90, 80, 70])
      end
    end

    context "budget with the hide money option" do
      before { budget.update!(voting_style: "approval", hide_money: true) }

      it "does not take the price into account" do
        create(:budget_investment, :selected, heading: heading, price: 100, ballot_lines_count: 50)
        create(:budget_investment, :incompatible, heading: heading, price: 300, ballot_lines_count: 80)
        create(:budget_investment, :selected, heading: heading, price: 800, ballot_lines_count: 70)
        create(:budget_investment, :selected, heading: heading, price: 500, ballot_lines_count: 60)

        Budget::Result.new(budget, heading).calculate_winners

        expect(heading.investments.winners.pluck(:ballot_lines_count)).to match_array([70, 60, 50])
      end
    end
  end
end
