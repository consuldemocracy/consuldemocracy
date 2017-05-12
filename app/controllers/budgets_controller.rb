class BudgetsController < ApplicationController
  include FeatureFlags
  feature_flag :budgets

  load_and_authorize_resource
  before_action :set_default_budget_filter, only: :show
  has_filters %w{not_unfeasible feasible unfeasible unselected selected}, only: :show

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
      @heading = parent
      @initial_budget = parent.price
    else
      parent = @budget
      @initial_budget = parent.headings.sum(:price)
    end
    @investments_selected = parent.investments.selected.order(cached_ballots_up: :desc)
  end

  def stats
  end

end
