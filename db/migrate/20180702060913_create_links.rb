class CreateLinks < ActiveRecord::Migration[4.2]
  def change
    create_table :links do |t|
      t.string :label
      t.string :url
      t.boolean :open_in_new_tab
      t.references :linkable, polymorphic: true, index: true

      t.timestamps null: false
    end
  end
end
