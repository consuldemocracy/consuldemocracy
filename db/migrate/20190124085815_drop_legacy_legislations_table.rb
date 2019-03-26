class DropLegacyLegislationsTable < ActiveRecord::Migration
  def change
    drop_table :legacy_legislations
  end
end
