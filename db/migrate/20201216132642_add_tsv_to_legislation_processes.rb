class AddTsvToLegislationProcesses < ActiveRecord::Migration[5.2]
  def change
    add_column :legislation_processes, :tsv, :tsvector
  end
end
