class DropAnnotationsTable < ActiveRecord::Migration[4.2]
  def change
    drop_table :annotations
  end
end
