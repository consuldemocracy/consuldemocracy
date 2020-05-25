class AddPeopleProposalsPhaseToLegislationProcesses < ActiveRecord::Migration[4.2]
  def change
    add_column :legislation_processes, :people_proposals_phase_start_date, :date
    add_column :legislation_processes, :people_proposals_phase_end_date, :date
    add_column :legislation_processes, :people_proposals_phase_enabled, :boolean
  end
end
