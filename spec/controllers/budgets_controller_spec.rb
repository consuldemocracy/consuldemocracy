require "rails_helper"

describe BudgetsController do
  describe "GET index" do
    it "raises an exception when the feature is disabled" do
      Setting["process.budgets"] = false

      expect { get :index }.to raise_exception(FeatureFlags::FeatureDisabled)
    end
  end

  describe "GET show" do
    it "raises an error if budget slug is not found" do
      expect do
        get :show, params: { id: "wrong_budget" }
      end.to raise_error ActiveRecord::RecordNotFound
    end

    it "raises an error if budget id is not found" do
      expect do
        get :show, params: { id: 0 }
      end.to raise_error ActiveRecord::RecordNotFound
    end

    context "drafting budget" do
      let(:budget) { create(:budget, published: false) }

      it "is not accesible to guest users" do
        expect do
          get :show, params: { id: budget.id }
        end.to raise_error(ActionController::RoutingError)
      end

      it "is not accesible to logged users" do
        sign_in(create(:user, :level_two))

        expect do
          get :show, params: { id: budget.id }
        end.to raise_error(ActionController::RoutingError)
      end

      it "is accesible to admin users", :admin do
        get :show, params: { id: budget.id }

        expect(response).to be_successful
      end
    end
  end
end
