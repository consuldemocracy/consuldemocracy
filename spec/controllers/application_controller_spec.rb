require "rails_helper"

describe ApplicationController do

  describe "#current_budget" do

    it "returns the last budget that is not in draft phase" do
      old_budget      = create(:budget, phase: "finished",  created_at: 2.years.ago)
      previous_budget = create(:budget, phase: "accepting", created_at: 1.year.ago)
      current_budget  = create(:budget, phase: "accepting", created_at: 1.month.ago)
      next_budget     = create(:budget, phase: "drafting",  created_at: 1.week.ago)

      budget = subject.instance_eval{ current_budget }
      expect(budget).to eq(current_budget)
    end

  end

end
