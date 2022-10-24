class AddPublishedToLegislationProcesses < ActiveRecord::Migration[4.2]
  def change
    add_column :legislation_processes, :published, :boolean, default: true
  end
end
