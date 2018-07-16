module Budgets
  class ExecutionsController < ApplicationController
    before_action :load_budget

    load_and_authorize_resource :budget

    def show
      authorize! :read_executions, @budget
      @statuses = Milestone::Status.all

      if params[:status].present?
        @investments_by_heading = @budget.investments.winners
                      .joins(:milestones).includes(:milestones)
                      .select { |i| i.milestones.published.with_status
                                                .order_by_publication_date.last
                                                .try(:status_id) == params[:status].to_i }
                      .uniq
                      .group_by(&:heading)
      else
        @investments_by_heading = @budget.investments.winners
                                         .joins(:milestones).includes(:milestones)
                                         .distinct.group_by(&:heading)
      end

      @investments_by_heading = reorder_alphabetically_with_city_heading_first.to_h
    end

    private

      def load_budget
        @budget = Budget.find_by(slug: params[:id]) || Budget.find_by(id: params[:id])
      end

      def reorder_alphabetically_with_city_heading_first
        @investments_by_heading.sort do |a, b|
          if a[0].city_heading?
            -1
          elsif b[0].city_heading?
            1
          else
            a[0].name <=> b[0].name
          end
        end
      end
  end
end
