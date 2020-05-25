class AddDraftPhaseToLegislationProcesses < ActiveRecord::Migration[4.2]
  def change
    add_column :legislation_processes, :draft_start_date, :date
    add_index :legislation_processes, :draft_start_date
    add_column :legislation_processes, :draft_end_date, :date
    add_index :legislation_processes, :draft_end_date
    add_column :legislation_processes, :draft_phase_enabled, :boolean, default: false
  end
end
