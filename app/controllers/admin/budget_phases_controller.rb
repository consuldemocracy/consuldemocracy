class Admin::BudgetPhasesController < Admin::BaseController
  include Translatable
  include ImageAttributes

  before_action :load_budget, only: [:index]
  before_action :load_phase, only: [:edit, :update, :toggle_enable]
  before_action :set_budget_mode, only: [:index, :edit, :update]
  before_action :set_url_params, only: [:index, :edit]

  def index
  end

  def edit
  end

  def update
    if @phase.update(budget_phase_params)
      notice = t("flash.actions.save_changes.notice")
      if @mode.present?
        redirect_to admin_budget_budget_phases_path(@phase.budget, url_params), notice: notice
      else
        redirect_to admin_budget_path(@phase.budget), notice: notice
      end
    else
      render :edit
    end
  end

  def toggle_enable
    @phase.update!(enabled: !@phase.enabled)
  end

  private

    def load_budget
      @budget = Budget.find_by_slug_or_id! params[:budget_id]
    end

    def load_phase
      @phase = Budget::Phase.find(params[:id])
    end

    def budget_phase_params
      valid_attributes = [:starts_at, :ends_at, :enabled,
                          :main_button_text, :main_button_url,
                          image_attributes: image_attributes]
      params.require(:budget_phase).permit(*valid_attributes, translation_params(Budget::Phase))
    end

    def url_params
      @mode.present? ? { mode: @mode } : {}
    end

    def set_url_params
      @url_params = url_params
    end

    def budget_mode_params
      params.require(:budget).permit(:mode) if params.key?(:budget)
    end

    def set_budget_mode
      if params[:mode] || budget_mode_params.present?
        @mode = params[:mode] || budget_mode_params[:mode]
      end
    end
end
