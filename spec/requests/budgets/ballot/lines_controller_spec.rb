require "rails_helper"

describe Budgets::Ballot::LinesController do
  describe "POST /budgets/:budget_id/ballot/lines" do
    it "does not create two ballots with two simultaneous requests", :race_condition do
      budget = create(:budget, :balloting)
      investment1 = create(:budget_investment, :selected, budget: budget)
      investment2 = create(:budget_investment, :selected, budget: budget)

      sign_in(create(:user, :level_two))
      path = budget_ballot_lines_path(budget)

      statuses = [investment1, investment2].map do |investment|
        Thread.new do
          post path, xhr: true, params: { budget_id: budget.id, investment_id: investment.id }
        end
      end.map(&:value)

      expect(statuses).to eq [200, 200]
      expect(Budget::Ballot.count).to eq 1
      expect(Budget::Ballot.first.investments).to match_array [investment1, investment2]
    end

    it "does not create two lines with two simultaneous requests", :race_condition do
      budget = create(:budget, :balloting)
      investment = create(:budget_investment, :selected, budget: budget)

      sign_in(create(:user, :level_two))
      path = budget_ballot_lines_path(budget)

      statuses = 2.times.map do
        Thread.new do
          post path, xhr: true, params: { budget_id: budget.id, investment_id: investment.id }
        end
      end.map(&:value)

      expect(statuses).to eq [200, 200]
      expect(Budget::Ballot.count).to eq 1
      expect(Budget::Ballot.first.investments).to eq [investment]
    end
  end
end
