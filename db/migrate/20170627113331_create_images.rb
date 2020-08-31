class CreateImages < ActiveRecord::Migration[4.2]
  def change
    create_table :images do |t|
      t.references :imageable, polymorphic: true, index: true
      t.string :title, limit: 80
      t.timestamps null: false
      t.string :attachment_file_name
      t.string :attachment_content_type
      t.integer :attachment_file_size
      t.datetime :attachment_updated_at
    end
  end
end
