require "rails_helper"

describe Admin::BudgetHeadingsController, :admin do
  context "processes disabled" do
    it "raises feature disabled for budgets" do
      Setting["process.budgets"] = nil
      group = create(:budget_group)

      expect do
        get :new, params: { budget_id: group.budget.id, group_id: group.id }
      end.to raise_exception(FeatureFlags::FeatureDisabled)
    end
  end

  describe "GET edit" do
    let(:heading) { create(:budget_heading) }

    it "raises an error if budget slug is not found" do
      expect do
        get :edit, params: { budget_id: "wrong_budget", group_id: heading.group.id, id: heading.id }
      end.to raise_error ActiveRecord::RecordNotFound
    end

    it "raises an error if budget id is not found" do
      expect do
        get :edit, params: { budget_id: 0, group_id: heading.group.id, id: heading.id }
      end.to raise_error ActiveRecord::RecordNotFound
    end

    it "raises an error if group slug is not found" do
      expect do
        get :edit, params: { budget_id: heading.budget.id, group_id: "wrong group", id: heading.id }
      end.to raise_error ActiveRecord::RecordNotFound
    end

    it "raises an error if group id is not found" do
      expect do
        get :edit, params: { budget_id: heading.budget.id, group_id: 0, id: heading.id }
      end.to raise_error ActiveRecord::RecordNotFound
    end

    it "raises an error if heading slug is not found" do
      expect do
        get :edit, params: { budget_id: heading.budget.id, group_id: heading.group.id, id: "wrong heading" }
      end.to raise_error ActiveRecord::RecordNotFound
    end

    it "raises an error if heading id is not found" do
      expect do
        get :edit, params: { budget_id: heading.budget.id, group_id: heading.group.id, id: 0 }
      end.to raise_error ActiveRecord::RecordNotFound
    end
  end
end
