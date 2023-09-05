require "rails_helper"

describe Budget do
  describe "#investments_preview_list" do
    let(:budget)  { create(:budget, :accepting) }
    let(:group)   { create(:budget_group, budget: budget) }
    let(:heading) { create(:budget_heading, group: group) }

    before do
      create_list(:budget_investment, 4, heading: heading)
      create_list(:budget_investment, 4, :feasible, heading: heading)
      create_list(:budget_investment, 4, :selected, heading: heading)
    end

    it "returns an empty array if phase is informing or finished" do
      %w[informing finished].each do |phase_name|
        budget.phase = phase_name

        expect(budget.investments_preview_list).to eq([])
      end
    end

    it "returns a maximum of 9 investments" do
      expect(Budget::Investment.count).to be 12
      expect(budget.investments_preview_list.count).to be 9
    end

    it "returns a different random array of investments every time" do
      expect(budget.investments_preview_list(3)).not_to eq budget.investments_preview_list(3)
    end

    it "returns only feasible investments if phase is selecting, valuating or publishing_prices" do
      %w[selecting valuating publishing_prices].each do |phase_name|
        budget.phase = phase_name

        expect(budget.investments_preview_list.count).to be budget.investments.feasible.count
      end
    end

    it "returns only selected investments if phase is balloting or reviewing_ballots" do
      %w[balloting reviewing_ballots].each do |phase_name|
        budget.phase = phase_name

        expect(budget.investments_preview_list.count).to be budget.investments.selected.count
      end
    end
  end
end
