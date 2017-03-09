class BudgetsController < ApplicationController
  include FeatureFlags
  feature_flag :budgets

  load_and_authorize_resource
  respond_to :html, :js

  def show
  end

  def index
    @budgets = @budgets.order(:created_at)
  end

end
