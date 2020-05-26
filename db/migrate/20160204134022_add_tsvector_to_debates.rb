class AddTsvectorToDebates < ActiveRecord::Migration[4.2]
  def up
    add_column :debates, :tsv, :tsvector
    add_index :debates, :tsv, using: "gin"
  end

  def down
    remove_index :debates, :tsv
    remove_column :debates, :tsv
  end
end
