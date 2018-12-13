class AddHomePageToLegislationProcesses < ActiveRecord::Migration
  def change
    add_column :legislation_processes, :homepage_enabled, :boolean, default: false

    reversible do |dir|
      dir.up do
        Legislation::Process.add_translation_fields! homepage: :text
      end

      dir.down do
        remove_column :legislation_process_translations, :homepage
      end
    end
  end
end
