module Admin::BudgetHeadingsActions
  extend ActiveSupport::Concern

  included do
    include Translatable
    include FeatureFlags
    feature_flag :budgets

    before_action :load_budget
    before_action :load_group
    before_action :load_heading, only: [:edit, :update, :destroy]
  end

  def edit
  end

  def create
    @heading = @group.headings.new(budget_heading_params)
    if @heading.save
      redirect_to headings_index, notice: t("admin.budget_headings.create.notice")
    else
      render new_action
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

    def budget_heading_params
      params.require(:budget_heading).permit(allowed_params)
    end

    def allowed_params
      valid_attributes = [:price, :population, :allow_custom_content, :latitude, :longitude, :max_ballot_lines]

      [*valid_attributes, translation_params(Budget::Heading)]
    end
end
