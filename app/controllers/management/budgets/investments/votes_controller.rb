class Management::Budgets::Investments::VotesController < Management::BaseController
  load_resource :budget, find_by: :slug_or_id
  load_resource :investment, through: :budget, class: "Budget::Investment"

  def create
    @investment.register_selection(managed_user)

    respond_to do |format|
      format.html do
        redirect_to management_budget_investments_path(heading_id: @investment.heading.id),
          notice: t("flash.actions.create.support")
      end

      format.js
    end
  end
end
