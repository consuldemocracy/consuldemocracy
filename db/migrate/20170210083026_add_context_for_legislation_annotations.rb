class AddContextForLegislationAnnotations < ActiveRecord::Migration
  def change
    add_column :legislation_annotations, :context, :text
  end
end
