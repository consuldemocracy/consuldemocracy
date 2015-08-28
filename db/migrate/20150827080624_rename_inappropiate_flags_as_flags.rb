class RenameInappropiateFlagsAsFlags < ActiveRecord::Migration
  def change
    rename_table :inappropiate_flags, :flags
  end
end
