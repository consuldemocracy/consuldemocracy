module Budgets
  class ExecutionsController < ApplicationController
    before_action :load_budget

    load_and_authorize_resource :budget

    def show
      authorize! :read_executions, @budget
      @statuses = ::Budget::Investment::Status.all
      @headings = @budget.headings.order(id: :asc)
    end

    private

      def load_budget
        @budget = Budget.find_by(slug: params[:id]) || Budget.find_by(id: params[:id])
      end

  end
end
