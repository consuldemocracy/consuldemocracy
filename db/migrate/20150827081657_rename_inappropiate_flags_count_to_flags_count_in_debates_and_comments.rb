class RenameInappropiateFlagsCountToFlagsCountInDebatesAndComments < ActiveRecord::Migration
  def change
    rename_column :debates,  :inappropiate_flags_count, :flags_count
    rename_column :comments, :inappropiate_flags_count, :flags_count
  end
end
