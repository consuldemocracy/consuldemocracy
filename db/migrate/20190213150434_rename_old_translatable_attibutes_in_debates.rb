class RenameOldTranslatableAttibutesInDebates < ActiveRecord::Migration
  def change
    remove_index :debates, :title

    rename_column :debates, :title, :deprecated_title
    rename_column :debates, :description, :deprecated_description
  end
end
