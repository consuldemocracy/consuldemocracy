require "rails_helper"

describe "duplicate role record removal tasks" do
  tasks = {
    "administrators:remove_duplicate_administrators" => Administrator,
    "managers:remove_duplicate_managers" => Manager,
    "moderators:remove_duplicate_moderators" => Moderator,
    "poll_officers:remove_duplicate_poll_officers" => Poll::Officer,
    "valuators:remove_duplicate_valuators" => Valuator
  }

  tasks.each do |task_name, model|
    describe task_name do
      before { Rake::Task[task_name].reenable }

      it "keeps the oldest record per user and deletes the rest" do
        user = create(:user)
        4.times { model.insert!({ user_id: user.id }) }
        2.times { model.insert!({ user_id: create(:user).id }) }
        oldest_id = model.where(user_id: user.id).order(:id).first.id

        Rake.application.invoke_task(task_name)

        expect(model.where(user_id: user.id).ids).to eq [oldest_id]
        expect(model.count).to eq 3
      end

      it "removes duplicate records on tenants" do
        create(:tenant, schema: "duplicate")
        user = Tenant.switch("duplicate") { create(:user) }

        Tenant.switch("duplicate") do
          2.times { model.insert!({ user_id: user.id }) }
        end

        Rake.application.invoke_task(task_name)

        Tenant.switch("duplicate") do
          expect(model.where(user_id: user.id).count).to eq 1
        end
      end
    end
  end

  describe "administrators:remove_duplicate_administrators" do
    before { Rake::Task["administrators:remove_duplicate_administrators"].reenable }

    let(:user) { create(:user) }
    let!(:original) { Administrator.create!(user: user) }
    let(:duplicate) do
      Administrator.insert!({ user_id: user.id })
      Administrator.where(user_id: user.id).where.not(id: original.id).first
    end

    it "assigns budget_administrators, investments and comments to the original" do
      budget = create(:budget)
      BudgetAdministrator.create!(budget: budget, administrator: duplicate)

      investment = create(:budget_investment, administrator: duplicate)
      comment = create(:comment, commentable: investment, user: user, administrator_id: duplicate.id)

      Rake.application.invoke_task("administrators:remove_duplicate_administrators")

      expect(Administrator.where(user_id: user.id).ids).to eq [original.id]
      expect(BudgetAdministrator.where(budget: budget).pluck(:administrator_id)).to eq [original.id]
      expect(investment.reload.administrator_id).to eq original.id
      expect(comment.reload.administrator_id).to eq original.id
    end

    it "does not generate a duplicate when both administrators were assigned to the same budget" do
      budget = create(:budget)
      BudgetAdministrator.create!(budget: budget, administrator: original)
      BudgetAdministrator.create!(budget: budget, administrator: duplicate)

      Rake.application.invoke_task("administrators:remove_duplicate_administrators")

      expect(BudgetAdministrator.where(budget: budget).pluck(:administrator_id)).to eq [original.id]
    end
  end

  describe "moderators:remove_duplicate_moderators" do
    before { Rake::Task["moderators:remove_duplicate_moderators"].reenable }

    let(:user) { create(:user) }
    let!(:original) { Moderator.create!(user: user) }
    let(:duplicate) do
      Moderator.insert!({ user_id: user.id })
      Moderator.where(user_id: user.id).where.not(id: original.id).first
    end

    it "assigns comments to the original" do
      comment = create(:comment, moderator_id: duplicate.id)

      Rake.application.invoke_task("moderators:remove_duplicate_moderators")

      expect(Moderator.where(user_id: user.id).ids).to eq [original.id]
      expect(comment.reload.moderator_id).to eq original.id
    end
  end

  describe "valuators:remove_duplicate_valuators" do
    before { Rake::Task["valuators:remove_duplicate_valuators"].reenable }

    let(:user) { create(:user) }
    let!(:original) { create(:valuator, user: user) }
    let(:duplicate) do
      Valuator.insert!({ user_id: user.id })
      Valuator.where(user_id: user.id).where.not(id: original.id).first
    end

    it "assigns budget_valuators and valuator assignments to the original and updates the counter" do
      budget = create(:budget)
      investment = create(:budget_investment)
      BudgetValuator.create!(budget: budget, valuator: duplicate)
      Budget::ValuatorAssignment.create!(investment: investment, valuator: duplicate)

      expect(original.reload.budget_investments_count).to eq 0

      Rake.application.invoke_task("valuators:remove_duplicate_valuators")

      expect(Valuator.where(user_id: user.id).ids).to eq [original.id]
      expect(BudgetValuator.where(budget: budget).pluck(:valuator_id)).to eq [original.id]
      expect(Budget::ValuatorAssignment.where(investment: investment).pluck(:valuator_id)).to eq [original.id]
      expect(original.reload.budget_investments_count).to eq 1
    end

    it "adds both original's and duplicate's investments to the counter" do
      Budget::ValuatorAssignment.create!(investment: create(:budget_investment), valuator: original)
      Budget::ValuatorAssignment.create!(investment: create(:budget_investment), valuator: duplicate)

      expect(original.reload.budget_investments_count).to eq 1

      Rake.application.invoke_task("valuators:remove_duplicate_valuators")

      expect(original.reload.budget_investments_count).to eq 2
    end

    it "does not generate a duplicate when both valuators were assigned to the same investment" do
      investment = create(:budget_investment)
      Budget::ValuatorAssignment.create!(investment: investment, valuator: original)
      Budget::ValuatorAssignment.create!(investment: investment, valuator: duplicate)

      Rake.application.invoke_task("valuators:remove_duplicate_valuators")

      expect(Budget::ValuatorAssignment.where(investment: investment).pluck(:valuator_id)).to eq [original.id]
      expect(original.reload.budget_investments_count).to eq 1
      expect(investment.reload.valuator_assignments_count).to eq 1
    end

    it "does not generate a duplicate when both valuators were assigned to the same budget" do
      budget = create(:budget)
      BudgetValuator.create!(budget: budget, valuator: original)
      BudgetValuator.create!(budget: budget, valuator: duplicate)

      Rake.application.invoke_task("valuators:remove_duplicate_valuators")

      expect(BudgetValuator.where(budget: budget).pluck(:valuator_id)).to eq [original.id]
    end
  end

  describe "poll_officers:remove_duplicate_poll_officers" do
    before { Rake::Task["poll_officers:remove_duplicate_poll_officers"].reenable }

    let(:user) { create(:user) }
    let!(:original) { create(:poll_officer, user: user) }
    let(:duplicate) do
      Poll::Officer.insert!({ user_id: user.id })
      Poll::Officer.where(user_id: user.id).where.not(id: original.id).first
    end

    it "assigns shifts, officer assignments, failed census calls and voters to the original" do
      create(:poll_shift, officer: duplicate)
      create(:poll_officer_assignment, officer: duplicate)
      create(:poll_voter, officer: duplicate)
      create(:failed_census_call, poll_officer: duplicate)

      Rake.application.invoke_task("poll_officers:remove_duplicate_poll_officers")

      expect(Poll::Officer.where(user_id: user.id).ids).to eq [original.id]
      expect(Poll::Shift.pluck(:officer_id)).to eq [original.id]
      expect(Poll::OfficerAssignment.pluck(:officer_id)).to eq [original.id]
      expect(Poll::Voter.pluck(:officer_id)).to eq [original.id]
    end

    it "adds both original's and duplicate's failed census calls to the counter" do
      create(:failed_census_call, poll_officer: duplicate)
      create(:failed_census_call, poll_officer: original)

      expect(original.reload.failed_census_calls_count).to eq 1

      Rake.application.invoke_task("poll_officers:remove_duplicate_poll_officers")

      expect(Poll::Officer.where(user_id: user.id).ids).to eq [original.id]
      expect(FailedCensusCall.where(poll_officer_id: original.id).count).to eq 2
      expect(original.reload.failed_census_calls_count).to eq 2
    end

    it "does not generate a duplicate when both officers were assigned to the same shift" do
      booth = create(:poll_booth)
      date = Date.current
      create(:poll_shift, officer: original, booth: booth, date: date)
      create(:poll_shift, officer: duplicate, booth: booth, date: date)

      Rake.application.invoke_task("poll_officers:remove_duplicate_poll_officers")

      expect(Poll::Shift.where(booth: booth, date: date).count).to eq 1
      expect(Poll::Shift.where(booth: booth, date: date, officer: original).count).to eq 1
    end
  end
end
