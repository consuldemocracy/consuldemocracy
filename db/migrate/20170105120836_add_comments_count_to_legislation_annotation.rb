class AddCommentsCountToLegislationAnnotation < ActiveRecord::Migration
  def change
    add_column :legislation_annotations, :comments_count, :integer, default: 0
  end
end
