module Budgets
  class ExecutionsController < ApplicationController
    before_action :load_budget

    load_and_authorize_resource :budget

    def show
      authorize! :read_executions, @budget
      @statuses = ::Budget::Investment::Status.all

      if params[:status].present?
        @investments_by_heading = @budget.investments.winners
                      .joins(:milestones).includes(:milestones)
                      .select { |i| i.milestones.published.with_status
                                                .order_by_publication_date.last
                                                .status_id == params[:status].to_i }
                      .uniq
                      .group_by(&:heading)
      else
        @investments_by_heading = @budget.investments.winners
                                         .joins(:milestones).includes(:milestones)
                                         .distinct.group_by(&:heading)
      end

      @headings = reorder_alphabetically_with_city_heading_first(@headings)
    end

    private

      def load_budget
        @budget = Budget.find_by(slug: params[:id]) || Budget.find_by(id: params[:id])
      end
  end
end
