module Budgets
  class ResultsController < ApplicationController
    before_action :load_budget
    before_action :load_heading

    load_and_authorize_resource :budget

    def show
      authorize! :read_results, @budget
      @investments = Budget::Result.new(@budget, @heading).investments
    end

    private

      def load_budget
        @budget = Budget.find_by(slug: params[:id]) || Budget.find_by(id: params[:id]) || Budget.first
      end

      def load_heading
        @heading = if params[:heading_id].present?
                     @budget.headings.find_by(slug: params[:heading_id])
                   else
                     @heading = @budget.headings.first
                   end
      end

  end
end
