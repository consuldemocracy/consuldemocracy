class CreateStats < ActiveRecord::Migration
  def change
    create_table :stats do |t|
      t.string :namespace
      t.string :group
      t.string :name
      t.integer :value

      t.timestamps
    end

    add_index :stats, :namespace
    add_index :stats, [:namespace, :group]
  end
end
