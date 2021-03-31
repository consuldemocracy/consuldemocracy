module Budgets
  class GroupsController < ApplicationController
    include InvestmentFilters
    include FeatureFlags
    feature_flag :budgets

    before_action :load_budget
    before_action :load_group
    authorize_resource :budget
    authorize_resource :group, class: "Budget::Group"

    before_action :set_default_investment_filter, only: :show
    has_filters investment_filters, only: [:show]

    def show
    end

    private

      def load_budget
        @budget = Budget.find_by_slug_or_id! params[:budget_id]
      end

      def load_group
        @group = @budget.groups.find_by_slug_or_id! params[:id]
      end
  end
end
