class RenameReviewedAtToArchivedAtInCommentsAndDebates < ActiveRecord::Migration[4.2]
  def change
    rename_column :comments, :reviewed_at, :archived_at
    rename_column :debates, :reviewed_at, :archived_at
  end
end
