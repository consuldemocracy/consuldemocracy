class Valuation::BudgetInvestmentsController < Valuation::BaseController
  include FeatureFlags
  feature_flag :budgets

  before_action :restrict_access_to_assigned_items, only: [:show, :edit, :valuate]
  before_action :load_budget
  before_action :load_investment, only: [:show, :edit, :valuate]

  has_filters %w{valuating valuation_finished}, only: :index

  load_and_authorize_resource :investment, class: "Budget::Investment"

  def index
    @heading_filters = heading_filters
    if current_user.valuator? && @budget.present?
      @investments = @budget.investments.scoped_filter(params_for_current_valuator, @current_filter).order(cached_votes_up: :desc).page(params[:page])
    else
      @investments = Budget::Investment.none.page(params[:page])
    end
  end

  def valuate
    if valid_price_params? && @investment.update(valuation_params)

      if @investment.unfeasible_email_pending?
        @investment.send_unfeasible_email
      end

      Activity.log(current_user, :valuate, @investment)
      redirect_to valuation_budget_budget_investment_path(@budget, @investment), notice: t('valuation.budget_investments.notice.valuate')
    else
      render action: :edit
    end
  end

  private

    def load_budget
      @budget = Budget.find(params[:budget_id])
    end

    def load_investment
      @investment = @budget.investments.find params[:id]
    end

    def heading_filters
      investments = @budget.investments.by_valuator(current_user.valuator.try(:id)).valuation_open.select(:heading_id).all.to_a

      [ { name: t('valuation.budget_investments.index.headings_filter_all'),
          id: nil,
          pending_count: investments.size
        }
      ] + Budget::Heading.where(id: investments.map(&:heading_id).uniq).order(name: :asc).collect do |h|
        { name: h.name,
          id: h.id,
          pending_count: investments.count{|x| x.heading_id == h.id}
        }
      end
    end

    def params_for_current_valuator
      Budget::Investment.filter_params(params).merge(valuator_id: current_user.valuator.id, budget_id: @budget.id)
    end

    def valuation_params
      params.require(:budget_investment).permit(:price, :price_first_year, :price_explanation, :feasibility, :unfeasibility_explanation, :duration, :valuation_finished, :internal_comments)
    end

    def restrict_access_to_assigned_items
      raise ActionController::RoutingError.new('Not Found') unless current_user.administrator? || Budget::ValuatorAssignment.exists?(investment_id: params[:id], valuator_id: current_user.valuator.id)
    end

    def valid_price_params?
      if /\D/.match params[:budget_investment][:price]
        @investment.errors.add(:price, I18n.t('budgets.investments.wrong_price_format'))
      end

      if /\D/.match params[:budget_investment][:price_first_year]
        @investment.errors.add(:price_first_year, I18n.t('budgets.investments.wrong_price_format'))
      end

      @investment.errors.empty?
    end

end
