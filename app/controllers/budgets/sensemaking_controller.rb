module Budgets
  class SensemakingController < ApplicationController
    before_action :load_budget

    authorize_resource :budget

    def show
      authorize! :read_sensemaking, @budget
      @sensemaker_jobs = Sensemaker::Job
                         .for_analysable(@budget, published_only: !admin_preview?)
                         .publishable_candidates
                         .order(finished_at: :desc)
    end

    private

      def admin_preview?
        current_user&.administrator?
      end

      def load_budget
        @budget = Budget.find_by_slug_or_id(params[:budget_id]) || Budget.first
      end
  end
end
