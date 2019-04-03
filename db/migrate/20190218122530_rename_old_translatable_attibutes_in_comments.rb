class RenameOldTranslatableAttibutesInComments < ActiveRecord::Migration
  def change
    rename_column :comments, :body, :deprecated_body
  end
end
