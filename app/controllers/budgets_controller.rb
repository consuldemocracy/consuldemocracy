class BudgetsController < ApplicationController
  include FeatureFlags
  include BudgetsHelper
  feature_flag :budgets

  before_action :load_budget, only: :show
  before_action :load_current_budget, only: :index
  before_action :load_map_locations, only: [:index, :show]
  before_action :load_banners, only: [:index, :show]
  before_action :load_investments, only: [:index, :show]
  load_and_authorize_resource
  before_action :set_default_budget_filter, only: [:index, :show]
  has_filters %w[not_unfeasible feasible unfeasible unselected selected winners], only: [:index, :show]

  respond_to :html, :js

  def show
    raise ActionController::RoutingError, "Not Found" unless budget_published?(@budget)
  end

  def index
    @finished_budgets = @budgets.finished.order(created_at: :desc)
  end

  private

    def load_budget
      @budget = Budget.find_by_slug_or_id! params[:id]
    end

    def load_current_budget
      @budget = current_budget
    end

    def load_map_locations
      @budgets_coordinates = budget_map_locations(@budget)
    end

    def load_banners
      @banners = Banner.in_section("budgets").with_active
    end

    def load_investments
      @investments = @budget&.investments_preview_list
      @investments ||= @current_budget&.investments_preview_list
    end
end
