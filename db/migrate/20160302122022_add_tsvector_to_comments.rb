class AddTsvectorToComments < ActiveRecord::Migration

  def up
    add_column :comments, :tsv, :tsvector
    add_index :comments, :tsv, using: "gin"
  end

  def down
    remove_index :comments, :tsv
    remove_column :comments, :tsv
  end

end
