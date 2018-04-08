class AddPublishedToLegislationProcesses < ActiveRecord::Migration
  def change
    add_column :legislation_processes, :published, :boolean, default: true
  end
end
