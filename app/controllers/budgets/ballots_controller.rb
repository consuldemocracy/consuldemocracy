module Budgets
  class BallotsController < ApplicationController
    before_action :authenticate_user!
    before_action :load_budget
    authorize_resource :budget
    before_action :load_ballot
    after_action :store_referer, only: [:show]

    def show
      authorize! :show, @ballot
      session[:ballot_referer] = request.referer
      render template: "budgets/ballot/show"
    end

    private

      def load_budget
        @budget = Budget.find_by_slug_or_id! params[:budget_id]
      end

      def load_ballot
        query = Budget::Ballot.where(user: current_user, budget: @budget)
        @ballot = @budget.balloting? ? query.first_or_create! : query.first_or_initialize
      end

      def store_referer
        session[:ballot_referer] = request.referer
      end
  end
end
