class Admin::BudgetGroupsController < Admin::BaseController
  include Translatable
  include FeatureFlags
  feature_flag :budgets

  before_action :load_budget
  before_action :load_groups, only: [:index, :create]
  before_action :load_group, except: [:new, :index, :create]
  before_action :set_budget_mode, only: [:index, :create]

  def index
    if @mode == "single"
      @group = @budget.groups.new("name_#{I18n.locale}" => @budget.name)
    else
      @group = @budget.groups.new
    end
  end

  def new
    @group = @budget.groups.new
  end

  def edit
  end

  def create
    @group = @budget.groups.new(budget_group_params)
    if @group.save
      notice = t("admin.budget_groups.create.notice")
      if @mode == "single"
        redirect_to admin_budget_group_headings_path(@group.budget, @group, url_params)
      elsif @mode == "multiple"
        redirect_to admin_budget_groups_path(@budget, url_params), notice: notice
      else
        redirect_to admin_budget_path(@budget), notice: notice
      end
    else
      render :index
    end
  end

  def update
    if @group.update(budget_group_params)
      redirect_to admin_budget_path(@budget), notice: t("admin.budget_groups.update.notice")
    else
      render :edit
    end
  end

  def destroy
    if @group.headings.any?
      redirect_to admin_budget_path(@budget), alert: t("admin.budget_groups.destroy.unable_notice")
    else
      @group.destroy!
      redirect_to admin_budget_path(@budget), notice: t("admin.budget_groups.destroy.success_notice")
    end
  end

  private

    def load_budget
      @budget = Budget.find_by_slug_or_id! params[:budget_id]
    end

    def load_groups
      @groups = @budget.groups.order(:id)
    end

    def load_group
      @group = @budget.groups.find_by_slug_or_id! params[:id]
    end

    def url_params
      @mode.present? ? { mode: @mode } : {}
    end

    def budget_group_params
      valid_attributes = [:max_votable_headings]
      params.require(:budget_group).permit(*valid_attributes, translation_params(Budget::Group))
    end

    def budget_heading_params
      params.require(:heading).permit(:mode) if params.key?(:heading)
    end

    def set_budget_mode
      if params[:mode] || budget_heading_params.present?
        @mode = params[:mode] || budget_heading_params[:mode]
      end
    end
end
