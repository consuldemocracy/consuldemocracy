require "rails_helper"

describe Budget::Investment do
  let(:investment) { build(:budget_investment) }

  describe "#feasibility_explanation blank" do
    it "is valid if valuation not finished" do
      investment.feasibility_explanation = ""
      investment.valuation_finished = false
      expect(investment).to be_valid
    end

    it "is valid if valuation finished and feasible" do
      investment.feasibility_explanation = ""
      investment.valuation_finished = true
      expect(investment).to be_valid
    end
  end

  describe "#should_show_feasibility_explanation?" do
    let(:budget) { create(:budget) }
    let(:investment) { create(:budget_investment, :feasible, :finished, budget: budget) }

    it "returns true for feasible investments with feasibility explanation and valuation finished" do
      Budget::Phase::PUBLISHED_PRICES_PHASES.each do |phase|
        budget.update!(phase: phase)

        expect(investment.should_show_feasibility_explanation?).to be true
      end
    end

    it "returns false if valuation has not finished" do
      investment.update!(valuation_finished: false)
      Budget::Phase::PUBLISHED_PRICES_PHASES.each do |phase|
        budget.update!(phase: phase)

        expect(investment.should_show_feasibility_explanation?).to be false
      end
    end

    it "returns false if investment is not feasible" do
      investment.update!(feasibility: "undecided")
      Budget::Phase::PUBLISHED_PRICES_PHASES.each do |phase|
        budget.update!(phase: phase)

        expect(investment.should_show_feasibility_explanation?).to be false
      end
    end

    it "returns false if feasibility explanation is blank" do
      investment.update!(feasibility_explanation: "")
      Budget::Phase::PUBLISHED_PRICES_PHASES.each do |phase|
        budget.update!(phase: phase)

        expect(investment.should_show_feasibility_explanation?).to be false
      end
    end
  end
end
