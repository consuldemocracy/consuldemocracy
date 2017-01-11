module Budgets
  class GroupsController < ApplicationController
    load_and_authorize_resource :budget, find_by: :slug
    load_and_authorize_resource :group, class: "Budget::Group", find_by: :slug

    def show
    end

  end
end