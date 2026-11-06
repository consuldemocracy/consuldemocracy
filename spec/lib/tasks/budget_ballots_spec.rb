require "rails_helper"

describe "budget ballots tasks" do
  describe "budget_ballots:remove_duplicate_budget_ballots" do
    before { Rake::Task["budget_ballots:remove_duplicate_budget_ballots"].reenable }

    it "keeps the first ballot with lines and deletes empty ballots" do
      user = create(:user)
      budget = create(:budget)
      investment = create(:budget_investment, :selected, budget: budget)

      2.times { Budget::Ballot.insert!({ user_id: user.id, budget_id: budget.id }) }
      ballot_ids = Budget::Ballot.where(user: user, budget: budget).order(:id).ids

      create(:budget_ballot_line, investment: investment, ballot: Budget::Ballot.find(ballot_ids[1]))

      Rake.application.invoke_task("budget_ballots:remove_duplicate_budget_ballots")

      expect(Budget::Ballot.where(user: user, budget: budget).ids).to eq [ballot_ids[1]]
      expect(Budget::Ballot.count).to eq 1
      expect(Budget::Ballot.find(ballot_ids[1]).ballot_lines_count).to eq 1
      expect(Budget::Ballot::Line.count).to eq 1
      expect(investment.reload.ballot_lines_count).to eq 1
    end

    it "keeps the oldest ballot when none of the duplicates have lines" do
      user = create(:user)
      budget = create(:budget)

      3.times { Budget::Ballot.insert!({ user_id: user.id, budget_id: budget.id }) }
      oldest_id = Budget::Ballot.where(user: user, budget: budget).order(:id).first.id

      Rake.application.invoke_task("budget_ballots:remove_duplicate_budget_ballots")

      expect(Budget::Ballot.where(user: user, budget: budget).ids).to eq [oldest_id]
    end

    it "keeps duplicate ballots containing ballot lines" do
      user = create(:user)
      budget = create(:budget)
      investment = create(:budget_investment, :selected, budget: budget)

      3.times { Budget::Ballot.insert!({ user_id: user.id, budget_id: budget.id }) }
      ballot_ids = Budget::Ballot.where(user: user, budget: budget).order(:id).ids

      create(:budget_ballot_line, investment: investment, ballot: Budget::Ballot.find(ballot_ids[1]))
      create(:budget_ballot_line, investment: investment, ballot: Budget::Ballot.find(ballot_ids[2]))

      Rake.application.invoke_task("budget_ballots:remove_duplicate_budget_ballots")

      expect(Budget::Ballot.where(user: user, budget: budget).ids).to eq [ballot_ids[1], ballot_ids[2]]
      expect(Budget::Ballot.count).to eq 2
      expect(Budget::Ballot.find(ballot_ids[1]).ballot_lines_count).to eq 1
      expect(Budget::Ballot.find(ballot_ids[2]).ballot_lines_count).to eq 1
      expect(Budget::Ballot::Line.count).to eq 2
      expect(investment.reload.ballot_lines_count).to eq 2
    end

    it "does not delete ballots from different budgets or different users" do
      budget = create(:budget)
      user = create(:user)

      create(:budget_ballot, budget: budget, user: user)
      create(:budget_ballot, budget: budget, user: create(:user))
      create(:budget_ballot, budget: create(:budget), user: user)
      create(:budget_ballot, budget: create(:budget), user: create(:user))
      Budget::Ballot.insert!({ user_id: user.id, budget_id: budget.id })

      Rake.application.invoke_task("budget_ballots:remove_duplicate_budget_ballots")

      expect(Budget::Ballot.count).to eq 4
      expect(Budget::Ballot.where(user: user, budget: budget).count).to eq 1
    end

    it "does not delete physical ballots without a user" do
      budget = create(:budget)

      2.times { create(:budget_ballot, budget: budget, user: nil, physical: true) }

      Rake.application.invoke_task("budget_ballots:remove_duplicate_budget_ballots")

      expect(Budget::Ballot.count).to eq 2
    end

    it "removes duplicate ballots on tenants" do
      create(:tenant, schema: "ballots")

      Tenant.switch("ballots") do
        user = create(:user)
        budget = create(:budget)
        2.times { Budget::Ballot.insert!({ user_id: user.id, budget_id: budget.id }) }
      end

      Rake.application.invoke_task("budget_ballots:remove_duplicate_budget_ballots")

      Tenant.switch("ballots") do
        expect(Budget::Ballot.count).to eq 1
      end
    end
  end
end
