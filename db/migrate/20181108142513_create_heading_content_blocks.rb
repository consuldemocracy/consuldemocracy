class CreateHeadingContentBlocks < ActiveRecord::Migration[4.2]
  def change
    create_table :budget_content_blocks do |t|
      t.integer :heading_id, index: true, foreign_key: true
      t.text :body
      t.string :locale
      t.timestamps null: false
    end
  end
end
