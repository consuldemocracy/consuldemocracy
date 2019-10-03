class Admin::HiddenBudgetInvestmentsController < Admin::BaseController
  include FeatureFlags

  has_filters %w[all with_confirmed_hide without_confirmed_hide], only: :index

  feature_flag :budgets

  before_action :load_investment, only: [:confirm_hide, :restore]

  def index
    @investments = Budget::Investment.only_hidden.send(@current_filter)
                                                 .order(hidden_at: :desc)
                                                 .page(params[:page])
  end

  def confirm_hide
    @investment.confirm_hide
    redirect_to request.params.merge(action: :index, only_path: true)
  end

  def restore
    @investment.restore(recursive: true)
    @investment.ignore_flag
    Activity.log(current_user, :restore, @investment)
    redirect_to request.param.merge(action: :index, only_path: true)
  end

  private

    def load_investment
      @investment = Budget::Investment.with_hidden.find(params[:id])
    end

end
