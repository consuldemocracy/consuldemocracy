class RenameDeprecatedTranslatableMilestoneFields < ActiveRecord::Migration[4.2]
  def change
    rename_column :milestones, :title, :deprecated_title
    rename_column :milestones, :description, :deprecated_description
  end
end
