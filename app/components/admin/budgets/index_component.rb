class Admin::Budgets::IndexComponent < ApplicationComponent
  include Header
  attr_reader :budgets

  def initialize(budgets)
    @budgets = budgets
  end

  def title
    t("admin.budgets.index.title")
  end

  private

    def phase_progress_text(budget)
      t("admin.budgets.index.table_phase_progress",
        current_phase_number: current_enabled_phase_number(budget),
        total_phases: budget.phases.enabled.count)
    end

    def current_enabled_phase_number(budget)
      current_enabled_phase_index(budget) + 1
    end

    def current_enabled_phase_index(budget)
      budget.phases.enabled.order(:id).pluck(:kind).index(budget.phase) || -1
    end

    def type(budget)
      if budget.single_heading?
        t("admin.budgets.index.type_single")
      elsif budget.headings.blank?
        t("admin.budgets.index.type_pending")
      else
        t("admin.budgets.index.type_multiple")
      end
    end

    def dates(budget)
      Admin::Budgets::DurationComponent.new(budget).dates
    end

    def duration(budget)
      Admin::Budgets::DurationComponent.new(budget).duration
    end

    def status_html_class(budget)
      if budget.drafting?
        "budget-draft"
      elsif budget.finished?
        "budget-completed"
      end
    end

    def status_text(budget)
      if budget.drafting?
        tag.span t("admin.budgets.index.table_draft")
      elsif budget.finished?
        tag.span t("admin.budgets.index.table_completed")
      end
    end
end
