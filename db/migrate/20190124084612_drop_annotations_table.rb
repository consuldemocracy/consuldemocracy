class DropAnnotationsTable < ActiveRecord::Migration
  def change
    drop_table :annotations
  end
end
