class RenameOldTranslatableAttibutesInComments < ActiveRecord::Migration[4.2]
  def change
    rename_column :comments, :body, :deprecated_body
  end
end
