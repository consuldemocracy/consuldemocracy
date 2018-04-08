class CreateTopics < ActiveRecord::Migration
  def change
    create_table :topics do |t|
      t.string :title, null: false
      t.text   :description
      t.integer :author_id
      t.integer  "comments_count", default: 0
      t.references :community, index: true
      t.datetime :hidden_at, index: true
      t.timestamps null: false
    end
  end
end
