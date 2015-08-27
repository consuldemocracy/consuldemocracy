class RenameArchivedAtToFlagIgnoredAtInCommentsAndDebates < ActiveRecord::Migration
  def change
    rename_column :comments, :archived_at, :flag_ignored_at
    rename_column :debates, :archived_at, :flag_ignored_at
  end
end
