module Budgets
  class SensemakingController < ApplicationController
    before_action :load_budget

    authorize_resource :budget

    def show
      authorize! :read_sensemaking, @budget
      @sensemaker_jobs = Sensemaker::Job.published.for_budget(@budget).order(finished_at: :desc)
    end

    private

      def load_budget
        @budget = Budget.find_by_slug_or_id(params[:budget_id]) || Budget.first
      end
  end
end
