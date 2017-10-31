class AddProposalsDescriptionToLegislationProcesses < ActiveRecord::Migration
  def change
    add_column :legislation_processes, :proposals_description, :text
  end
end
