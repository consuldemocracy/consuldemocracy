require_dependency Rails.root.join("app", "controllers", "budgets", "results_controller").to_s

module Budgets
  class ResultsController < ApplicationController
    def show
      authorize! :read_results, @budget
      @investments = Budget::Result.new(@budget, @heading).investments
      @headings = @budget.headings.order(:id)
    end

    private
      def load_heading
        if @budget.present?
          headings = @budget.headings.order(:id)
          @heading = headings.find_by_slug_or_id(params[:heading_id]) || headings.first
        end
      end
  end
end
