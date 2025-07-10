require "rails_helper"

describe Budget::Result do
  describe "calculate_winners" do
    let(:budget) { create(:budget) }
    let(:heading) { create(:budget_heading, budget: budget, price: 1000) }

    context "When there are no winners" do
      it "assigns investments ordered by ballot lines until budget is met" do
        create(:budget_investment, :selected, heading: heading, price: 100, ballot_lines_count: 500)
        create(:budget_investment, :selected, heading: heading, price: 300, ballot_lines_count: 800)
        create(:budget_investment, :selected, heading: heading, price: 200, ballot_lines_count: 900)
        create(:budget_investment, :selected, heading: heading, price: 500, ballot_lines_count: 600)

        Budget::Result.new(budget, heading).calculate_winners

        expect(heading.investments.winners.pluck(:ballot_lines_count)).to match_array([900, 800, 600])
      end

      it "selects cheaper investments when running out of budget" do
        create(:budget_investment, :selected, heading: heading, price: 800, ballot_lines_count: 900)
        create(:budget_investment, :selected, heading: heading, price: 300, ballot_lines_count: 800)
        create(:budget_investment, :selected, heading: heading, price: 200, ballot_lines_count: 600)

        Budget::Result.new(budget, heading).calculate_winners

        expect(heading.investments.winners.pluck(:ballot_lines_count)).to match_array([900, 600])
      end

      it "excludes incompatible investments" do
        create(:budget_investment, :selected, heading: heading, price: 200, ballot_lines_count: 900)
        create(:budget_investment, :selected, heading: heading, price: 300, ballot_lines_count: 800)
        create(:budget_investment, :incompatible, heading: heading, price: 500, ballot_lines_count: 700)
        create(:budget_investment, :selected, heading: heading, price: 500, ballot_lines_count: 600)
        create(:budget_investment, :selected, heading: heading, price: 100, ballot_lines_count: 500)

        Budget::Result.new(budget, heading).calculate_winners

        expect(heading.investments.winners.pluck(:ballot_lines_count)).to match_array([900, 800, 600])
      end
    end

    context "When there are winners" do
      it "removes winners and recalculates" do
        create(:budget_investment, :selected, heading: heading, price: 200, ballot_lines_count: 900)
        create(:budget_investment, :winner, heading: heading, price: 300, ballot_lines_count: 800)
        create(:budget_investment, :winner, :incompatible, heading: heading, price: 500, ballot_lines_count: 700)
        create(:budget_investment, :winner, heading: heading, price: 500, ballot_lines_count: 600)
        create(:budget_investment, :winner, heading: heading, price: 100, ballot_lines_count: 500)

        Budget::Result.new(budget, heading).calculate_winners

        expect(heading.investments.winners.pluck(:ballot_lines_count)).to match_array([900, 800, 600])
      end
    end

    context "When a winner is flagged as incompatible" do
      it "recalculates winners leaving it out" do
        wrong_win = create(:budget_investment, :winner, heading: heading, price: 200, ballot_lines_count: 900)

        create(:budget_investment, :winner, heading: heading, price: 300, ballot_lines_count: 800)
        create(:budget_investment, :winner, heading: heading, price: 500, ballot_lines_count: 700)
        create(:budget_investment, :winner, heading: heading, price: 200, ballot_lines_count: 600)
        create(:budget_investment, :winner, heading: heading, price: 100, ballot_lines_count: 500)

        wrong_win.update!(incompatible: true)

        expect(heading.investments.winners.pluck(:ballot_lines_count)).to match_array([800, 700, 600])
      end
    end

    context "When an incompatible is flagged as compatible again" do
      it "recalculates winners taking it in consideration" do
        miss = create(:budget_investment, :incompatible, heading: heading, price: 200, ballot_lines_count: 900)

        create(:budget_investment, :winner, heading: heading, price: 300, ballot_lines_count: 800)
        create(:budget_investment, :winner, heading: heading, price: 500, ballot_lines_count: 700)
        create(:budget_investment, :winner, heading: heading, price: 200, ballot_lines_count: 600)
        create(:budget_investment, :winner, heading: heading, price: 100, ballot_lines_count: 500)

        miss.update!(incompatible: false)

        expect(heading.investments.winners.pluck(:ballot_lines_count)).to match_array([900, 800, 700])
      end
    end
  end
end
