class RemovePeopleProposalPhaseFromLegislationProcess < ActiveRecord::Migration[5.0]
  def change
    remove_column :legislation_processes, :people_proposals_phase_start_date, :date
    remove_column :legislation_processes, :people_proposals_phase_end_date, :date
    remove_column :legislation_processes, :people_proposals_phase_enabled, :boolean
  end
end
