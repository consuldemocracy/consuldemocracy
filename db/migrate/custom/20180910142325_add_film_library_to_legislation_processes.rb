class AddFilmLibraryToLegislationProcesses < ActiveRecord::Migration
  def change
    add_column :legislation_processes, :film_library, :boolean, default: false
  end
end
