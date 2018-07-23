module Budgets
  class ExecutionsController < ApplicationController
    before_action :load_budget

    load_and_authorize_resource :budget

    def show
      authorize! :read_executions, @budget
      @statuses = ::Budget::Investment::Status.all
      @headings = @budget.headings
                         .includes(investments: :milestones)
                         .joins(investments: :milestones)
                         .distinct
                         .order(id: :asc)

      if params[:status].present?
        @headings = @headings.where(filter_investment_by_latest_milestone, params[:status])
      end

      @headings = reorder_with_city_heading_first(@headings)
    end

    private

      def load_budget
        @budget = Budget.find_by(slug: params[:id]) || Budget.find_by(id: params[:id])
      end

      def filter_investment_by_latest_milestone
        <<-SQL
          (SELECT status_id FROM budget_investment_milestones
           WHERE investment_id = budget_investments.id ORDER BY publication_date DESC LIMIT 1) = ?
        SQL
      end

      def reorder_with_city_heading_first(original_headings)
        headings = original_headings.to_a.dup

        city_heading_index = headings.find_index do |heading|
          heading.name == "Toda la ciudad"
        end

        if city_heading_index
          headings.insert(0, headings.delete_at(city_heading_index))
        else
          headings
        end
      end
  end
end
