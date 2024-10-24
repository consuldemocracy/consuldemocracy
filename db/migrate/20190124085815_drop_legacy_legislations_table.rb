class DropLegacyLegislationsTable < ActiveRecord::Migration[4.2]
  def up
    drop_table :legacy_legislations
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
