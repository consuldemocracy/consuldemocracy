require 'rails_helper'

describe Budget do
  describe "phase" do
    let(:budget) { create(:budget) }

    it "is validated" do
      Budget::VALID_PHASES.each do |phase|
        budget.phase = phase
        expect(budget).to be_valid
      end

      budget.phase = 'inexisting'
      expect(budget).to_not be_valid
    end

    it "produces auxiliary methods" do
      budget.phase = "on_hold"
      expect(budget).to be_on_hold

      budget.phase = "accepting"
      expect(budget).to be_accepting

      budget.phase = "selecting"
      expect(budget).to be_selecting

      budget.phase = "balloting"
      expect(budget).to be_balloting

      budget.phase = "finished"
      expect(budget).to be_finished
    end
  end

  describe "heading_price" do
    let(:budget) { create(:budget) }
    let(:group) { create(:budget_group, budget: budget) }

    it "returns the heading price if the heading provided is part of the budget" do
      heading = create(:budget_heading, price: 100, group: group)
      expect(budget.heading_price(heading)).to eq(100)
    end

    xit "returns -1 if the heading provided is not part of the budget" do
      expect(budget.heading_price(create(:budget_heading))).to eq(-1)
    end
  end
end

