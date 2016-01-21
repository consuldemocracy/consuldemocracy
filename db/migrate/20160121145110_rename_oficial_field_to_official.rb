class RenameOficialFieldToOfficial < ActiveRecord::Migration
  def change
    rename_column :proposals, :oficial, :official
  end
end
