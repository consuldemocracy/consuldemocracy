class AddContextForLegislationAnnotations < ActiveRecord::Migration[4.2]
  def change
    add_column :legislation_annotations, :context, :text
  end
end
