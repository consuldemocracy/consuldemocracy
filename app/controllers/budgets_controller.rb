class BudgetsController < ApplicationController
  include FeatureFlags
  feature_flag :budgets

  load_and_authorize_resource
  respond_to :html, :js

  def show
  end

  def index
    @budgets = @budgets.order(:created_at)
    @current_budget = Budget.current_budget
    @last_budget = Budget.last_budget
  end

  def results
    if params[:heading_id].present?
      parent = @budget.headings.find(params[:heading_id])
      @total_price = parent.price
    else
      parent = @budget
      @total_price = parent.headings.sum(:price)
    end
    @investments_selected = parent.investments.selected.order(cached_ballots_up: :desc)
  end

  def stats
  end

end
