class Admin::Budgets::ActionsComponent < ApplicationComponent
  attr_reader :budget

  def initialize(budget)
    @budget = budget
  end

  private

    def action(action_name, **options)
      render Admin::ActionComponent.new(
        action_name,
        budget,
        "aria-describedby": true,
        **options
      )
    end

    def actions
      @actions ||= {
        calculate_winners: {
          hint: winners_hint,
          html: winners_action
        },
        destroy: {
          hint: destroy_hint,
          html: destroy_action
        }
      }.select { |_, button| button[:html].present? }
    end

    def winners_action
      render Admin::Budgets::CalculateWinnersButtonComponent.new(budget)
    end

    def winners_hint
      t("admin.budgets.actions.descriptions.calculate_winners", phase: t("budgets.phase.finished"))
    end

    def destroy_action
      action(:destroy,
             text: t("admin.budgets.edit.delete"),
             method: :delete,
             confirm: t("admin.budgets.actions.confirm.destroy"),
             disabled: budget.investments.any? || budget.poll)
    end

    def destroy_hint
      if budget.investments.any?
        t("admin.budgets.destroy.unable_notice")
      elsif budget.poll
        t("admin.budgets.destroy.unable_notice_polls")
      else
        t("admin.budgets.actions.descriptions.destroy")
      end
    end

    def descriptor_id(action_name)
      "#{dom_id(budget, action_name)}_descriptor"
    end
end
