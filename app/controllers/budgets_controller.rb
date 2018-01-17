class BudgetsController < ApplicationController
  include FeatureFlags
  include BudgetsHelper
  feature_flag :budgets

  load_and_authorize_resource
  before_action :set_default_budget_filter, only: :show
  has_filters %w{not_unfeasible feasible unfeasible unselected selected}, only: :show

  respond_to :html, :js

  def show
    raise ActionController::RoutingError, 'Not Found' unless budget_published?(@budget)
  end

  def index
    @budgets = @budgets.order(:created_at)
    @budget = current_budget
    budgets_map_locations = current_budget.investments.map{ |investment| investment.map_location }.compact
    @budgets_coordinates = budgets_map_locations.map{ |ml| {lat: ml.latitude, long: ml.longitude, investment_title: ml.investment.title , investment_id: ml.investment.id, budget_id: ml.investment.budget.id}}
  end

end
