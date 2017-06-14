module Budgets
  class ResultsController < ApplicationController
    before_action :load_budget

    load_and_authorize_resource :budget

    def show
      authorize! :read_results, @budget
      @result = load_result
    end

    private

      def load_result
        Budget::Result.new(@budget, heading)
      end

      def load_budget
        @budget = Budget.find_by(slug: params[:budget_id])
      end

      def heading
        @budget.headings.find_by(slug: params[:heading_id])
      end

  end
end