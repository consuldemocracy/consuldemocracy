class RenameInappropiateFlagsAsFlags < ActiveRecord::Migration[4.2]
  def change
    rename_table :inappropiate_flags, :flags
  end
end
