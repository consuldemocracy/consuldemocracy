class AddPresentationSummaryToBudgetPhases < ActiveRecord::Migration[4.2]
  def change
    add_column :budget_phases, :presentation_summary_accepting, :text
    add_column :budget_phases, :presentation_summary_balloting, :text
    add_column :budget_phases, :presentation_summary_finished, :text

    add_column :budget_phase_translations, :presentation_summary_accepting, :string
    add_column :budget_phase_translations, :presentation_summary_balloting, :string
    add_column :budget_phase_translations, :presentation_summary_finished, :string
  end
end
