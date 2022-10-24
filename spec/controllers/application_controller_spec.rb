require "rails_helper"

describe ApplicationController do
  describe "#current_budget" do
    it "returns the last budget that is not in draft phase" do
      create(:budget, :finished,  created_at: 2.years.ago, name: "Old")
      create(:budget, :accepting, created_at: 1.year.ago,  name: "Previous")
      create(:budget, :accepting, created_at: 1.month.ago, name: "Current")
      create(:budget, :drafting,  created_at: 1.week.ago,  name: "Next")

      budget = subject.instance_eval { current_budget }
      expect(budget.name).to eq("Current")
    end
  end
end
