module Budgets
  class ExecutionsController < ApplicationController
    include DownloadSettingsHelper
    before_action :load_budget

    load_and_authorize_resource :budget

    def show
      authorize! :read_executions, @budget
      @statuses = Milestone::Status.all
      @investments_by_heading = investments_by_heading_ordered_alphabetically.to_h
      downloadables = []
      investments_by_heading_ordered_alphabetically
        .map { |heading| downloadables.concat heading[1] }

      respond_to do |format|
        format.html
        format.csv { send_data to_csv(downloadables,
                                      Budget::Investment,
                                      1),
                               type: "text/csv",
                               disposition: "attachment",
                               filename: "budget_investment_milestones.csv" }
      end
    end

    private
      def investments_by_heading
        base = @budget.investments.winners
        base = base.joins(milestones: :translations).includes(:milestones)
        base = base.tagged_with(params[:milestone_tag]) if params[:milestone_tag].present?

        if params[:status].present?
          base = base.with_milestone_status_id(params[:status])
          base.uniq.group_by(&:heading)
        else
          base.distinct.group_by(&:heading)
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
