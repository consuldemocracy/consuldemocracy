class DropLegacyLegislationsTable < ActiveRecord::Migration[4.2]
  def change
    drop_table :legacy_legislations
  end
end
