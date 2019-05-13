class AddRangesFieldsToLegislationAnnotations < ActiveRecord::Migration[4.2]
  def change
    add_column :legislation_annotations, :range_start, :string
    add_column :legislation_annotations, :range_start_offset, :integer
    add_column :legislation_annotations, :range_end, :string
    add_column :legislation_annotations, :range_end_offset, :integer

    add_index :legislation_annotations, [:range_start, :range_end]
  end
end
