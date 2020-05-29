class RemoveRelatedContentsFlagsCount < ActiveRecord::Migration[4.2]
  def change
    remove_column :related_contents, :flags_count, :integer
  end
end
