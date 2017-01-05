class Valuation::BudgetsController < Valuation::BaseController
  include FeatureFlags
  feature_flag :budgets

  load_and_authorize_resource

  def index
    @budgets = @budgets.current.order(created_at: :desc).page(params[:page])
    @investments_with_valuation_open = {}
    @budgets.each do |b|
      @investments_with_valuation_open[b.id] = b.investments
                                                .by_valuator(current_user.valuator.try(:id))
                                                .valuation_open
                                                .count
    end
  end
end
