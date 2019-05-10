module Budgets
  class ExecutionsController < ApplicationController
    before_action :load_budget

    load_and_authorize_resource :budget

    def show
      authorize! :read_executions, @budget
      @statuses = Milestone::Status.all
      @investments_by_heading = investments_by_heading_ordered_alphabetically.to_h
    end

    private
      def investments_by_heading
        if params[:status].present?
          @budget.investments.winners
                  .with_milestone_status_id(params[:status])
                  .uniq
                  .group_by(&:heading)
        else
          @budget.investments.winners
                  .joins(milestones: :translations)
                  .distinct.group_by(&:heading)
        end
      end

      def load_budget
        @budget = Budget.find_by_slug_or_id params[:budget_id]
      end

      def investments_by_heading_ordered_alphabetically
        investments_by_heading.sort { |a, b| a[0].name <=> b[0].name }
      end
  end
end
