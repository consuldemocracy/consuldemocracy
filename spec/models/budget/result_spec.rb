require 'rails_helper'

describe Budget::Result do

  describe "calculate_winners" do
    let(:budget) { create(:budget) }
    let(:group) { create(:budget_group, budget: budget) }
    let(:heading) { create(:budget_heading, group: group, price: 1000) }

    it "calculates a budget's winner investments" do
      investment1 = create(:budget_investment, :selected, heading: heading, price: 200, ballot_lines_count: 900)
      investment2 = create(:budget_investment, :selected, heading: heading, price: 300, ballot_lines_count: 800)
      investment3 = create(:budget_investment, :selected, heading: heading, price: 500, ballot_lines_count: 700)
      investment4 = create(:budget_investment, :selected, heading: heading, price: 100, ballot_lines_count: 600)

      result = Budget::Result.new(budget, heading)
      result.calculate_winners

      expect(result.winners).to eq([investment1, investment2, investment3])
    end

    it "resets winners before recalculating" do
      investment1 = create(:budget_investment, :selected, heading: heading, price: 200, ballot_lines_count: 900, winner: true)
      investment2 = create(:budget_investment, :selected, heading: heading, price: 300, ballot_lines_count: 800, winner: true)
      investment3 = create(:budget_investment, :selected, heading: heading, price: 500, ballot_lines_count: 700, winner: true)
      investment4 = create(:budget_investment, :selected, heading: heading, price: 100, ballot_lines_count: 600, winner: true)

      result = Budget::Result.new(budget, heading)
      result.calculate_winners

      expect(result.winners).to eq([investment1, investment2, investment3])
    end
  end

end