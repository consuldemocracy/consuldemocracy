class AddMedidasCounterToTags < ActiveRecord::Migration
  def change
    add_column :tags, :medidas_count, :integer, default: 0
    add_index :tags, :medidas_count
  end
end
