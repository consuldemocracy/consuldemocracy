module Budgets
  class GroupsController < ApplicationController

    before_action :set_default_budget_filter, only: :show
    has_filters %w{not_unfeasible feasible unfeasible unselected selected}, only: [:show]

    def show
      begin
        @budget = Budget.find_by(id: params[:budget_id])
        @group = @budget.groups.find_by(id: params[:id])
      rescue
        raise ActionController::RoutingError, 'Not Found'
      end
      authorize! :show, @budget
      authorize! :show, @group
    end

  end
end
