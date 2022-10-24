class Admin::HiddenBudgetInvestmentsController < Admin::BaseController
  include FeatureFlags
  include Admin::HiddenContent

  feature_flag :budgets

  before_action :load_investment, only: [:confirm_hide, :restore]

  def index
    @investments = hidden_content(Budget::Investment.all)
  end

  def confirm_hide
    @investment.confirm_hide
    redirect_with_query_params_to(action: :index)
  end

  def restore
    @investment.restore(recursive: true)
    @investment.ignore_flag
    Activity.log(current_user, :restore, @investment)
    redirect_with_query_params_to(action: :index)
  end

  private

    def load_investment
      @investment = Budget::Investment.with_hidden.find(params[:id])
    end
end
