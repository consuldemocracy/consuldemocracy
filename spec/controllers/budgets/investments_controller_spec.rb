require "rails_helper"

describe Budgets::InvestmentsController do
  describe "GET index" do
    it "raises an exception when the feature is disabled" do
      Setting["process.budgets"] = false

      expect do
        get :index, params: { budget_id: create(:budget).id }
      end.to raise_exception(FeatureFlags::FeatureDisabled)
    end

    context "balloting" do
      let!(:budget) { create(:budget, :balloting) }

      it "does not create a ballot for anonymous users" do
        get :index, params: { budget_id: budget.id }

        expect(response).to be_successful
        expect(Budget::Ballot.count).to eq 0
      end

      it "does not create a ballot for authorized users" do
        sign_in(create(:user, :level_two))

        get :index, params: { budget_id: budget.id }

        expect(response).to be_successful
        expect(Budget::Ballot.count).to eq 0
      end

      context "physical ballots" do
        render_views

        it "does not mark a physical ballot's investments as voted to anonymous users" do
          investment = create(:budget_investment, :selected, budget: budget)
          create(:budget_ballot, budget: budget, user: nil, physical: true, investments: [investment])

          get :index, params: { budget_id: budget.id }

          expect(response).to be_successful
          expect(response.body).to include "Vote"
          expect(response.body).not_to include "Remove vote"
        end
      end
    end
  end

  describe "GET show" do
    let(:investment) { create(:budget_investment) }

    it "raises an error if budget slug is not found" do
      expect do
        get :show, params: { budget_id: "wrong_budget", id: investment.id }
      end.to raise_error ActiveRecord::RecordNotFound
    end

    it "raises an error if budget id is not found" do
      expect do
        get :show, params: { budget_id: 0, id: investment.id }
      end.to raise_error ActiveRecord::RecordNotFound
    end

    it "raises an error if heading slug is not found" do
      expect do
        get :show, params: { budget_id: investment.budget.id, id: investment.id, heading_id: "wrong_heading" }
      end.to raise_error ActiveRecord::RecordNotFound
    end

    it "raises an error if heading id is not found" do
      expect do
        get :show, params: { budget_id: investment.budget.id, id: investment.id, heading_id: 0 }
      end.to raise_error ActiveRecord::RecordNotFound
    end

    context "balloting" do
      before { investment.budget.update!(phase: "balloting") }

      it "does not create a ballot for anonymous users" do
        get :show, params: { budget_id: investment.budget.id, id: investment.id }

        expect(response).to be_successful
        expect(Budget::Ballot.count).to eq 0
      end

      it "does not create a ballot for authorized users" do
        sign_in(create(:user, :level_two))

        get :show, params: { budget_id: investment.budget.id, id: investment.id }

        expect(response).to be_successful
        expect(Budget::Ballot.count).to eq 0
      end

      context "physical ballots" do
        render_views

        it "does not mark a physical ballot's investments as voted to anonymous users" do
          budget = create(:budget, :balloting)
          investment = create(:budget_investment, :selected, budget: budget)
          create(:budget_ballot, budget: budget, user: nil, physical: true, investments: [investment])

          get :show, params: { budget_id: budget.id, id: investment.id }

          expect(response).to be_successful
          expect(response.body).to include "Vote"
          expect(response.body).not_to include "Remove vote"
        end
      end
    end
  end
end
