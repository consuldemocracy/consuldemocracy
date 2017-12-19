class AddRelatedContentsPositiveAndNegativeScore < ActiveRecord::Migration
  def change
    remove_column :related_contents, :flags_count

    add_column :related_contents, :positive_score, :integer, default: 1
    add_column :related_contents, :negative_score, :integer, default: 0
  end
end
