class BudgetsController < ApplicationController
  include FeatureFlags
  include BudgetsHelper
  include InvestmentFilters
  feature_flag :budgets

  before_action :load_budget, only: :show
  load_and_authorize_resource
  before_action :set_default_investment_filter, only: :show
  has_filters investment_filters, only: :show

  respond_to :html, :js

  def show
    raise ActionController::RoutingError, "Not Found" unless budget_published?(@budget)
  end

  def index
    @finished_budgets = @budgets.finished.order(created_at: :desc)
    @budgets_coordinates = current_budget_map_locations
  end

  private

    def load_budget
      @budget = Budget.find_by_slug_or_id! params[:id]
    end
end
