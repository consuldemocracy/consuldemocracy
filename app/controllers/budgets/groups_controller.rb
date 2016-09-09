module Budgets
  class GroupsController < ApplicationController
    load_and_authorize_resource :budget
    load_and_authorize_resource :group, class: "Budget::Group"

    def show
    end

  end
end