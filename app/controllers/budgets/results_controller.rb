module Budgets
  class ResultsController < ApplicationController
    before_action :load_budget
    before_action :load_heading

    load_and_authorize_resource :budget

    def show
      authorize! :read_results, @budget
      @investments = load_result.investments
    end

    private

      def load_result
        Budget::Result.new(@budget, @heading)
      end

      def load_budget
        @budget = Budget.find_by(id: params[:budget_id])
      end

      def load_heading
        if params[:heading_id].present?
          @heading = @budget.headings.find(params[:heading_id])
        else
          @heading = @budget.headings.first
        end
      end

  end
end
