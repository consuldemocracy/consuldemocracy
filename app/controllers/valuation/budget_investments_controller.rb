class Valuation::BudgetInvestmentsController < Valuation::BaseController
  include FeatureFlags
  include CommentableActions

  feature_flag :budgets

  before_action :restrict_access_to_assigned_items, only: [:show, :edit, :valuate]
  before_action :restrict_access, only: [:edit, :valuate]
  before_action :load_budget
  before_action :load_investment, only: [:show, :edit, :valuate]

  has_orders %w{oldest}, only: [:show, :edit]
  has_filters %w{valuating valuation_finished}, only: :index

  load_and_authorize_resource :investment, class: "Budget::Investment"

  def index
    @heading_filters = heading_filters
    @investments = if current_user.valuator? && @budget.present?
                     @budget.investments.visible_to_valuators.scoped_filter(params_for_current_valuator, @current_filter)
                            .order(cached_votes_up: :desc)
                            .page(params[:page])
                   else
                     Budget::Investment.none.page(params[:page])
                   end
  end

  def valuate
    if valid_price_params? && @investment.update(valuation_params)

      if @investment.unfeasible_email_pending?
        @investment.send_unfeasible_email
      end

      Activity.log(current_user, :valuate, @investment)
      notice = t('valuation.budget_investments.notice.valuate')
      redirect_to valuation_budget_budget_investment_path(@budget, @investment), notice: notice
    else
      render action: :edit
    end
  end

  def show
    load_comments
  end

  def edit
    load_comments
  end

  private

    def load_comments
      @commentable = @investment
      @comment_tree = CommentTree.new(@commentable, params[:page], @current_order, valuations: true)
      set_comment_flags(@comment_tree.comments)
    end

    def resource_model
      Budget::Investment
    end

    def resource_name
      resource_model.parameterize('_')
    end

    def load_budget
      @budget = Budget.find(params[:budget_id])
    end

    def load_investment
      @investment = @budget.investments.find params[:id]
    end

    def heading_filters
      investments = @budget.investments.by_valuator(current_user.valuator.try(:id))
                                       .visible_to_valuators.distinct

      investment_headings = Budget::Heading.where(id: investments.pluck(:heading_id).uniq)
                                           .order(name: :asc)

      all_headings_filter = [
                              {
                                name: t('valuation.budget_investments.index.headings_filter_all'),
                                id: nil,
                                count: investments.size
                              }
                            ]

      filters = investment_headings.inject(all_headings_filter) do |filters, heading|
                  filters << {
                               name: heading.name,
                               id: heading.id,
                               count: investments.select{|i| i.heading_id == heading.id}.size
                             }
                end
    end

    def params_for_current_valuator
      Budget::Investment.filter_params(params).merge(valuator_id: current_user.valuator.id,
                                                     budget_id: @budget.id)
    end

    def valuation_params
      params.require(:budget_investment).permit(:price, :price_first_year, :price_explanation,
                                                :feasibility, :unfeasibility_explanation,
                                                :duration, :valuation_finished)
    end

    def restrict_access
      unless current_user.administrator? || current_budget.valuating?
        raise CanCan::AccessDenied.new(I18n.t('valuation.budget_investments.not_in_valuating_phase'))
      end
    end

    def restrict_access_to_assigned_items
      return if current_user.administrator? ||
                Budget::ValuatorAssignment.exists?(investment_id: params[:id],
                                                   valuator_id: current_user.valuator.id)
      raise ActionController::RoutingError.new('Not Found')
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
