module Budgets
  class RecommendationsController < ApplicationController
    include FeatureFlags
    feature_flag :budgets

    before_action :authenticate_user!, except: [:index]

    before_action :load_budget
    before_action :load_phase
    before_action :load_user, only: [:index]
    before_action :load_ballot, only: [:index]

    load_and_authorize_resource :budget

    def index
      @investments = @user.budget_recommendations.includes(:investment).by_budget(@budget.id).by_phase(@phase).map(&:investment)
      @investment_ids = @investments.map(&:id)
      load_investment_votes(@investments)
    end

    def new
      @recommendations = current_user.budget_recommendations.includes(:investment).by_budget(@budget.id).by_phase(@phase)
    end

    def create
      investment = ::Budget::Investment.find(recommendation_params[:investment_id]) rescue nil
      feedback = { alert: I18n.t("delegation.create_error") }
      if investment
        ::Budget::Recommendation.create(user: current_user, investment_id: investment.id, budget_id: investment.budget_id, phase: @phase)
        feedback = { notice: I18n.t("delegation.create_ok") }
      end
      redirect_to new_budget_recommendation_path(budget_id: @budget.id), feedback
    end

    def destroy
      recommendation = current_user.budget_recommendations.find(params[:id])
      recommendation.destroy
      redirect_to new_budget_recommendation_path(budget_id: @budget.id), notice: I18n.t("delegation.deleted")
    end

    private

      def load_user
        @user = params[:user_id].present? ? User.find(params[:user_id]) : current_user
      end

      def load_budget
        @budget = Budget.find_by(slug: params[:budget_id]) || Budget.find_by(id: params[:budget_id])
      end

      def load_phase
        @phase = @budget.balloting_or_later? ? "balloting" : "selecting"
      end

      def load_ballot
        query = Budget::Ballot.where(user: current_user, budget: @budget)
        @ballot = @budget.balloting? ? query.first_or_create : query.first_or_initialize
      end

      def load_investment_votes(investments)
        @investment_votes = current_user ? current_user.budget_investment_votes(investments) : {}
      end

      def recommendation_params
        params.require(:recommendation).permit(:investment_id)
      end
  end
end