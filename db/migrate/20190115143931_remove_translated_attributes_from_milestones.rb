class RemoveTranslatedAttributesFromMilestones < ActiveRecord::Migration
  def change
    remove_columns :milestones, :title, :description
  end
end
