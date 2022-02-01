class Admin::Budgets::LinksComponent < ApplicationComponent
  attr_reader :budget
  delegate :can?, to: :helpers

  def initialize(budget)
    @budget = budget
  end

  private

    def action(action_name, **options)
      render Admin::ActionComponent.new(action_name, budget, **options)
    end

    def results_text
      if Abilities::Everyone.new(User.new).can?(:read_results, budget)
        t("budgets.show.see_results")
      else
        t("admin.budgets.actions.preview_results")
      end
    end

    def preview_text
      if budget.published?
        t("admin.shared.view")
      else
        t("admin.budgets.actions.preview")
      end
    end
end
