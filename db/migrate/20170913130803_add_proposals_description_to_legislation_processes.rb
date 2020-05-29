class AddProposalsDescriptionToLegislationProcesses < ActiveRecord::Migration[4.2]
  def change
    add_column :legislation_processes, :proposals_description, :text
  end
end
