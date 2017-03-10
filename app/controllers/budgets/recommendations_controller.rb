module Budgets
  class RecommendationsController < ApplicationController
    include FeatureFlags
    feature_flag :budgets

    before_action :authenticate_user!, except: [:index]

    before_action :load_budget
    before_action :load_user, only: [:index]
    before_action :load_ballot, only: [:index]

    load_and_authorize_resource :budget

    def index
      @investments = @user.budget_recommendations.includes(:investment).by_budget(@budget.id).map(&:investment)
      @investment_ids = @investments.map(&:id)
      load_investment_votes(@investments)
    end

    private

      def load_user
        @user = params[:user_id].present? ? User.find(params[:user_id]) : current_user
      end

      def load_budget
        @budget = Budget.find_by(slug: params[:budget_id]) || Budget.find_by(id: params[:budget_id])
      end

      def load_ballot
        query = Budget::Ballot.where(user: current_user, budget: @budget)
        @ballot = @budget.balloting? ? query.first_or_create : query.first_or_initialize
      end

      def load_investment_votes(investments)
        @investment_votes = current_user ? current_user.budget_investment_votes(investments) : {}
      end
  end
end