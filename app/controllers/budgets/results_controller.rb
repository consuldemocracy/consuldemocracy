module Budgets
  class ResultsController < ApplicationController

    load_and_authorize_resource :budget

    def show
      authorize! :read_results, @budget
      @investments = load_result.investments
      @heading = heading
    end

    private

      def load_result
        Budget::Result.new(@budget, heading)
      end

      def heading
        @budget.headings.find(params[:heading_id])
      end

  end
end
