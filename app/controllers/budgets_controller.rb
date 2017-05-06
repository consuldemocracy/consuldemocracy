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
  end

end
