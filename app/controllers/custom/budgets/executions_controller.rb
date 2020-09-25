require_dependency Rails.root.join("app", "controllers", "budgets", "executions_controller").to_s

module Budgets
  class ExecutionsController < ApplicationController
    def show
      authorize! :read_executions, @budget
      @statuses = Milestone::Status.all
      @investments_by_heading = investments_by_heading_ordered_by_id.to_h
    end

    private

      def investments_by_heading_ordered_by_id
        investments_by_heading.sort { |a, b| a[0].id <=> b[0].id }
      end
  end
end
