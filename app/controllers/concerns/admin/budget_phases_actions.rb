module Admin::BudgetPhasesActions
  extend ActiveSupport::Concern

  included do
    include Translatable

    before_action :load_budget
    before_action :load_phase, only: [:edit, :update]
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

  private

    def load_budget
      @budget = Budget.find_by_slug_or_id!(params[:budget_id])
    end

    def load_phase
      @phase = @budget.phases.find(params[:id])
    end

    def budget_phase_params
      valid_attributes = [:starts_at, :ends_at, :enabled]
      params.require(:budget_phase).permit(*valid_attributes, translation_params(Budget::Phase))
    end
end
