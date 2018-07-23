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
                         .order(name: :asc)

      if params[:status].present?
        @headings = @headings.where(filter_investment_by_latest_milestone, params[:status])
      end

      @headings = reorder_alphabetically_with_city_heading_first(@headings)
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

      def reorder_alphabetically_with_city_heading_first(headings)
        headings.sort do |a, b|
          if a.name == 'Toda la ciudad'
            -1
          elsif b.name == 'Toda la ciudad'
            1
          else
            a.name <=> b.name
          end
        end
      end
  end
end
