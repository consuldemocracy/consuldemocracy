class Admin::BudgetsWizard::CreationStepComponent < Admin::BudgetsWizard::BaseComponent
  attr_reader :record, :next_step_path

  def initialize(record, next_step_path)
    @record = record
    @next_step_path = next_step_path
  end

  private

    def show_form?
      record.errors.any?
    end

    def i18n_namespace
      i18n_namespace_with_budget.gsub("budget_", "")
    end

    def i18n_namespace_with_budget
      record.class.table_name
    end
end
