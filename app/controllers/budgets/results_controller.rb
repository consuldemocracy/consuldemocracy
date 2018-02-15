module Budgets
  class ResultsController < ApplicationController
    before_action :load_budget_by_budget_id
    before_action :load_heading

    load_and_authorize_resource :budget

    def show
      authorize! :read_results, @budget
      @investments = Budget::Result.new(@budget, @heading).investments
    end

    private

      def load_heading
        @heading = if params[:heading_id].present?
                     @budget.headings.find(params[:heading_id])
                   else
                     @budget.headings.first
                   end
      end

  end
end
