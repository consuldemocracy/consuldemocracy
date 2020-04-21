require "rails_helper"

describe Budgets::InvestmentsListComponent, type: :component do
  describe "#investments_preview_list" do
    let(:budget)    { create(:budget, :accepting) }
    let(:group)     { create(:budget_group, budget: budget) }
    let(:heading)   { create(:budget_heading, group: group) }
    let(:component) { Budgets::InvestmentsListComponent.new(budget) }

    let!(:normal_investments)   { create_list(:budget_investment, 4, heading: heading) }
    let!(:feasible_investments) { create_list(:budget_investment, 4, :feasible, heading: heading) }
    let!(:selected_investments) { create_list(:budget_investment, 4, :selected, heading: heading) }

    it "returns an empty relation if phase is informing or finished" do
      %w[informing finished].each do |phase_name|
        budget.phase = phase_name

        expect(component.investments).to be_empty
      end
    end

    it "returns a maximum 9 investments by default" do
      expect(budget.investments.count).to be 12
      expect(component.investments.count).to be 9
    end

    it "returns a different random array of investments every time" do
      expect(component.investments(limit: 7)).not_to eq component.investments(limit: 7)
    end

    it "returns any investments while accepting and reviewing" do
      %w[accepting reviewing].each do |phase_name|
        budget.phase = phase_name

        investments = component.investments(limit: 9)

        expect(investments & normal_investments).not_to be_empty
        expect(investments & feasible_investments).not_to be_empty
        expect(investments & selected_investments).not_to be_empty
      end
    end

    it "returns only feasible investments if phase is selecting, valuating or publishing_prices" do
      %w[selecting valuating publishing_prices].each do |phase_name|
        budget.phase = phase_name

        investments = component.investments(limit: 6)

        expect(feasible_investments + selected_investments).to include(*investments)
      end
    end

    it "returns only selected investments if phase is balloting or reviewing_ballots" do
      %w[balloting reviewing_ballots].each do |phase_name|
        budget.phase = phase_name

        investments = component.investments(limit: 3)

        expect(selected_investments).to include(*investments)
      end
    end
  end
end
