class Admin::BudgetsController < Admin::BaseController
  include Translatable
  include ReportAttributes
  include FeatureFlags
  feature_flag :budgets

  has_filters %w{open finished}, only: :index

  before_action :load_budget, except: [:index, :new, :create]
  load_and_authorize_resource

  def index
    @budgets = Budget.send(@current_filter).order(created_at: :desc).page(params[:page])
  end

  def show
  end

  def new
    load_admins
    load_valuators
    load_trackers
  end

  def edit
    load_admins
    load_valuators
    load_trackers
  end

  def calculate_winners
    return unless @budget.balloting_process?
    @budget.headings.each { |heading| Budget::Result.new(@budget, heading).delay.calculate_winners }
    redirect_to admin_budget_budget_investments_path(
                  budget_id: @budget.id,
                  advanced_filters: ["winners"]),
                notice: I18n.t("admin.budgets.winners.calculated")
  end

  def update
    if @budget.update(budget_params)
      redirect_to admin_budgets_path, notice: t("admin.budgets.update.notice")
    else
      load_admins
      load_valuators
      load_trackers
      render :edit
    end
  end

  def create
    @budget = Budget.new(budget_params)
    if @budget.save
      redirect_to admin_budget_path(@budget), notice: t("admin.budgets.create.notice")
    else
      load_admins
      load_valuators
      load_trackers
      render :new
    end
  end

  def destroy
    if @budget.investments.any?
      redirect_to admin_budgets_path, alert: t("admin.budgets.destroy.unable_notice")
    elsif @budget.poll.present?
      redirect_to admin_budgets_path, alert: t("admin.budgets.destroy.unable_notice_polls")
    else
      @budget.destroy
      redirect_to admin_budgets_path, notice: t("admin.budgets.destroy.success_notice")
    end
  end

  def assigned_users_translation
    render json: { administrators: t("admin.budgets.edit.administrators", count: params[:administrators].to_i),
                   valuators: t("admin.budgets.edit.valuators", count: params[:valuators].to_i),
                   trackers: t("admin.budgets.edit.trackers", count: params[:trackers].to_i)
    }
  end

  private

    def budget_params
      descriptions = Budget::Phase::PHASE_KINDS.map{|p| "description_#{p}"}.map(&:to_sym)
      valid_attributes = [:phase,
                          :currency_symbol,
                          :help_link,
                          :budget_milestone_tags,
                          :budget_valuation_tags,
                          administrator_ids: [],
                          valuator_ids: [],
                          tracker_ids: []
      ] + descriptions
      params.require(:budget).permit(*valid_attributes, *report_attributes, translation_params(Budget))
    end

    def load_budget
      @budget = Budget.find_by_slug_or_id! params[:id]
    end

    def load_admins
      @admins = Administrator.includes(:user).all
    end

    def load_trackers
      @trackers = Tracker.includes(:user).all.order(description: :asc).order("users.email ASC")
    end

    def load_valuators
      @valuators = Valuator.includes(:user).all.order(description: :asc).order("users.email ASC")
    end

end
