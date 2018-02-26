class CreateArticles < ActiveRecord::Migration
  def change
    create_table :articles do |t|
      t.string :slug, null: false, index: true
      t.string :title, null: false
      t.string :subtitle
      t.text :content
      t.integer :author_id
      t.string :status, default: "draft"
      t.timestamps null: false
    end
  end
end
