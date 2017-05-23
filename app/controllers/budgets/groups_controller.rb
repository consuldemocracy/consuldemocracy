module Budgets
  class GroupsController < ApplicationController
    load_and_authorize_resource :budget
    load_and_authorize_resource :group, class: "Budget::Group"

    before_action :set_default_budget_filter, only: :show
    has_filters %w{not_unfeasible feasible unfeasible unselected selected}, only: [:show]

    def show
    end

  end
end