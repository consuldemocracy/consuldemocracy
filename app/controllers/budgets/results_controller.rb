module Budgets
  class ResultsController < ApplicationController
    before_action :load_budget
    authorize_resource :budget

    def show
      authorize! :read_results, @budget
    end

    private

      def load_budget
        @budget = Budget.find_by_slug_or_id(params[:budget_id]) || Budget.first
      end
  end
end
