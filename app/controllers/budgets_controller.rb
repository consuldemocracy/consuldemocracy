class BudgetsController < ApplicationController
  include FeatureFlags
  feature_flag :budgets

  before_action :load_budget
  load_and_authorize_resource
  respond_to :html, :js

  def show
  end

  def index
    @budgets = @budgets.order(:created_at)
  end

  private

  def load_budget
    @budget = Budget.find_by(slug: params[:id]) || Budget.find_by(id: params[:id])
  end

end
