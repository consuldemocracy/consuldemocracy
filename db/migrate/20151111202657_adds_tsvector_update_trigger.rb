class AddsTsvectorUpdateTrigger < ActiveRecord::Migration

  def up
    add_column :proposals, :tsv, :tsvector
    add_index :products, :tsv, using: "gin"
  end

  def down
    remove_index :products, :tsv
    remove_column :proposals, :tsv
  end

end
