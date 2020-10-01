class AddHomePageToLegislationProcesses < ActiveRecord::Migration[4.2]
  def change
    add_column :legislation_processes, :homepage_enabled, :boolean, default: false
    add_column :legislation_process_translations, :homepage, :text
  end
end
