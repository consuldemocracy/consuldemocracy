module Admin::BudgetPhasesActions
  extend ActiveSupport::Concern

  included do
    include Translatable
    include ImageAttributes

    before_action :load_budget
    before_action :load_phase, only: [:edit, :update, :enable, :disable]
  end

  def edit
  end

  def update
    if @phase.update(budget_phase_params)
      redirect_to phases_index, notice: t("flash.actions.save_changes.notice")
    else
      render :edit
    end
  end

  def enable
    @phase.update!(enabled: true)

    respond_to do |format|
      format.html { redirect_to phases_index, notice: t("flash.actions.save_changes.notice") }
      format.js { render template: "admin/budgets_wizard/phases/toggle_enabled" }
    end
  end

  def disable
    @phase.update!(enabled: false)

    respond_to do |format|
      format.html { redirect_to phases_index, notice: t("flash.actions.save_changes.notice") }
      format.js { render template: "admin/budgets_wizard/phases/toggle_enabled" }
    end
  end

  private

    def load_budget
      @budget = Budget.find_by_slug_or_id!(params[:budget_id])
    end

    def load_phase
      @phase = @budget.phases.find(params[:id])
    end

    def budget_phase_params
      params.require(:budget_phase).permit(allowed_params)
    end

    def allowed_params
      valid_attributes = [:starts_at, :ends_at, :enabled,
                          image_attributes: image_attributes]

      [*valid_attributes, translation_params(Budget::Phase)]
    end
end
