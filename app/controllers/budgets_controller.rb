class BudgetsController < ApplicationController
  include FeatureFlags
  include BudgetsHelper
  include Search
  feature_flag :budgets

  before_action :load_budget
  load_and_authorize_resource
  before_action :set_default_budget_filter, only: :show
  has_filters %w{not_unfeasible feasible unfeasible unselected selected}, only: :show

  respond_to :html, :js

  def show
    raise ActionController::RoutingError, 'Not Found' unless budget_published?(@budget)
  end

  def index
    @budgets = @budgets.order(created_at: :desc)
    @budget = current_budget
    @budgets_coordinates = current_budget_map_locations
  end

  private

  def load_budget
    @budget = Budget.find_by(slug: params[:id]) || Budget.find_by(id: params[:id])
  end

end
