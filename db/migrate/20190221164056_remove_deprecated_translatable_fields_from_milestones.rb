class RemoveDeprecatedTranslatableFieldsFromMilestones < ActiveRecord::Migration
  def change
    remove_column :milestones, :title, :string
    remove_column :milestones, :description, :text
  end
end
