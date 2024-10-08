require "rails_helper"

describe Admin::BudgetInvestmentsController, :admin do
  describe "GET index" do
    it "raises an exception when the feature is disabled" do
      Setting["process.budgets"] = false

      expect do
        get :index, params: { budget_id: create(:budget).id }
      end.to raise_exception(FeatureFlags::FeatureDisabled)
    end

    it "raises an error if budget slug is not found" do
      expect do
        get :index, params: { budget_id: "wrong_budget" }
      end.to raise_error ActiveRecord::RecordNotFound
    end

    it "raises an error if budget id is not found" do
      expect do
        get :index, params: { budget_id: 0 }
      end.to raise_error ActiveRecord::RecordNotFound
    end
  end

  describe "PATCH update" do
    it "does not redirect on AJAX requests" do
      investment = create(:budget_investment)

      patch :update, params: {
        id: investment,
        budget_id: investment.budget,
        format: :json,
        budget_investment: { visible_to_valuators: true }
      }

      expect(response).not_to be_redirect
    end
  end

  describe "PATCH select" do
    let(:investment) { create(:budget_investment, :feasible, :finished) }

    it "selects the investment" do
      expect do
        patch :select, xhr: true, params: { id: investment, budget_id: investment.budget }
      end.to change { investment.reload.selected? }.from(false).to(true)

      expect(response).to be_successful
    end

    it "does not modify already selected investments" do
      investment.update!(selected: true)

      expect do
        patch :select, xhr: true, params: { id: investment, budget_id: investment.budget }
      end.not_to change { investment.reload.selected? }
    end

    it "uses the select/deselect authorization rules" do
      investment.update!(valuation_finished: false)

      patch :select, xhr: true, params: { id: investment, budget_id: investment.budget }

      expect(flash[:alert]).to eq "You do not have permission to carry out the action " \
                                  "'select' on Investment."
      expect(investment).not_to be_selected
    end
  end

  describe "PATCH deselect" do
    let(:investment) { create(:budget_investment, :feasible, :finished, :selected) }

    it "deselects the investment" do
      expect do
        patch :deselect, xhr: true, params: { id: investment, budget_id: investment.budget }
      end.to change { investment.reload.selected? }.from(true).to(false)

      expect(response).to be_successful
    end

    it "does not modify non-selected investments" do
      investment.update!(selected: false)

      expect do
        patch :deselect, xhr: true, params: { id: investment, budget_id: investment.budget }
      end.not_to change { investment.reload.selected? }
    end

    it "uses the select/deselect authorization rules" do
      investment.update!(valuation_finished: false)

      patch :deselect, xhr: true, params: { id: investment, budget_id: investment.budget }

      expect(flash[:alert]).to eq "You do not have permission to carry out the action " \
                                  "'deselect' on Investment."
      expect(investment).to be_selected
    end
  end
end
