class AddPhasePubEnabledStatusToLegislativeProcess < ActiveRecord::Migration[4.2]
  def change
    add_column :legislation_processes, :debate_phase_enabled, :boolean, default: false
    add_column :legislation_processes, :allegations_phase_enabled, :boolean, default: false
    add_column :legislation_processes, :draft_publication_enabled, :boolean, default: false
    add_column :legislation_processes, :result_publication_enabled, :boolean, default: false
  end
end
