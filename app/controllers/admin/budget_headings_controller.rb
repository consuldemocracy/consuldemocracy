class Admin::BudgetHeadingsController < Admin::BaseController
  include Translatable
  include FeatureFlags
  feature_flag :budgets

  before_action :load_budget
  before_action :load_group
  before_action :load_heading, except: [:index, :new, :create]
  before_action :set_budget_mode, only: [:new, :create]

  def index
    @headings = @group.headings.order(:id)
  end

  def new
    @heading = @group.headings.new
  end

  def edit
  end

  def create
    @heading = @group.headings.new(budget_heading_params)
    if @heading.save
      if @mode == "single"
        redirect_to admin_budget_path(@heading.group.budget), notice: t("admin.budgets.create.notice")
      else
        redirect_to headings_index, notice: t("admin.budget_headings.create.notice")
      end
    else
      render :new
    end
  end

  def update
    if @heading.update(budget_heading_params)
      redirect_to headings_index, notice: t("admin.budget_headings.update.notice")
    else
      render :edit
    end
  end

  def destroy
    if @heading.can_be_deleted?
      @heading.destroy!
      redirect_to headings_index, notice: t("admin.budget_headings.destroy.success_notice")
    else
      redirect_to headings_index, alert: t("admin.budget_headings.destroy.unable_notice")
    end
  end

  private

    def load_budget
      @budget = Budget.find_by_slug_or_id! params[:budget_id]
    end

    def load_group
      @group = @budget.groups.find_by_slug_or_id! params[:group_id]
    end

    def load_heading
      @heading = @group.headings.find_by_slug_or_id! params[:id]
    end

    def headings_index
      admin_budget_group_headings_path(@budget, @group)
    end

    def budget_heading_params
      valid_attributes = [:price, :population, :allow_custom_content, :latitude, :longitude]
      params.require(:budget_heading).permit(*valid_attributes, translation_params(Budget::Heading))
    end

    def budget_mode_params
      params.require(:budget).permit(:mode) if params.key?(:budget)
    end

    def set_budget_mode
      if params[:mode] || budget_mode_params
        @mode = params[:mode] || budget_mode_params[:mode]
      else
        @mode = "multiple"
      end
    end
end
