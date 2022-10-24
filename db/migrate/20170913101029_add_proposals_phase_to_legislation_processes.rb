class AddProposalsPhaseToLegislationProcesses < ActiveRecord::Migration[4.2]
  def change
    add_column :legislation_processes, :proposals_phase_start_date, :date
    add_column :legislation_processes, :proposals_phase_end_date, :date
    add_column :legislation_processes, :proposals_phase_enabled, :boolean
  end
end
