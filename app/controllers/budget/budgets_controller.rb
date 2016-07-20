class Budget
  class BudgetsController < ApplicationController
    load_and_authorize_resource

    def index
      @budgets = Budget.all
    end

  end
end