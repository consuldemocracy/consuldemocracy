class RemoveDeprecatedTranslatableFieldsFromMilestones < ActiveRecord::Migration[4.2]
  def change
    remove_column :milestones, :title, :string
    remove_column :milestones, :description, :text
  end
end
