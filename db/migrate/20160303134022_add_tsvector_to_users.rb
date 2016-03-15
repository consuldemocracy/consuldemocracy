class AddTsvectorToUsers < ActiveRecord::Migration

  def up
    add_column :users, :tsv, :tsvector
    add_index :users, :tsv, using: "gin"
  end

  def down
    remove_index :users, :tsv
    remove_column :users, :tsv
  end

end
