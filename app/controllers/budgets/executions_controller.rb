module Budgets
  class ExecutionsController < ApplicationController
    before_action :load_budget
    before_action :load_heading
    before_action :load_investments

    load_and_authorize_resource :budget

    def show
      authorize! :read_executions, @budget
      @statuses = ::Budget::Investment::Status.all
    end

    private

      def load_budget
        @budget = Budget.find_by(slug: params[:id]) || Budget.find_by(id: params[:id])
      end

      def load_heading
        @heading = if params[:heading_id].present?
                     @budget.headings.find_by(slug: params[:heading_id])
                   else
                     @heading = @budget.headings.first
                   end
      end

      def load_investments
        @investments = Budget::Result.new(@budget, @heading).investments.joins(:milestones)

        if params[:status].present?
          @investments.where('budget_investment_milestones.status_id = ?', params[:status])
        else
          @investments
        end
      end

  end
end
