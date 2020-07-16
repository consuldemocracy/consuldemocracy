require_dependency Rails.root.join("app", "controllers", "budgets", "results_controller").to_s

module Budgets
  class ResultsController < ApplicationController
    private
      def load_heading
        if @budget.present?
          headings = @budget.headings.order(:name)
          @heading = headings.find_by_slug_or_id(params[:heading_id]) || headings.first
        end
      end
  end
end
