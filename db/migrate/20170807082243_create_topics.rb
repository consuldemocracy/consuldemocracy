class CreateTopics < ActiveRecord::Migration
  def change
    create_table :topics do |t|
      t.string :title, null: false
      t.integer :author_id
      t.references :community, index: true
      t.timestamps null: false
    end
  end
end
