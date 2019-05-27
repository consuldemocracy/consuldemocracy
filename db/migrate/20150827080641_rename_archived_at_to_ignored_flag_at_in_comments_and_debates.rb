class RenameArchivedAtToIgnoredFlagAtInCommentsAndDebates < ActiveRecord::Migration[4.2]
  def change
    rename_column :comments, :archived_at, :ignored_flag_at
    rename_column :debates, :archived_at, :ignored_flag_at
  end
end
