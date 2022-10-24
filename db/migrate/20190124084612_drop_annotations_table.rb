class DropAnnotationsTable < ActiveRecord::Migration[4.2]
  def up
    drop_table :annotations
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
