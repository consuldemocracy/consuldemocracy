class CreateImages < ActiveRecord::Migration
  def up
    create_table :images do |t|
      t.references :imageable, polymorphic: true, index: true
      t.string :title, limit: 80
      t.timestamps null: false
    end
    add_attachment :images, :attachment
  end

  def down
    remove_attachment :images, :attachment
  end
end
