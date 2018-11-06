class RemoveRelatedContentsFlagsCount < ActiveRecord::Migration
  def change
    remove_column :related_contents, :flags_count
  end
end
