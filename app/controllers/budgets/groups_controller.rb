module Budgets
  class GroupsController < ApplicationController
    before_action :load_budget
    before_action :load_group, only: :show
    load_and_authorize_resource :budget
    load_and_authorize_resource :group, class: "Budget::Group"

    before_action :set_default_budget_filter, only: [:index, :show]
    has_filters %w[not_unfeasible feasible unfeasible unselected selected winners], only: [:index, :show]

    private

      def load_budget
        @budget = Budget.find_by_slug_or_id! params[:budget_id]
      end

      def load_group
        @group = @budget.groups.find_by_slug_or_id! params[:id]
      end
  end
end
