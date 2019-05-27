class CreateDebates < ActiveRecord::Migration[4.2]
  def change
    create_table :debates do |t|
      t.string :title
      t.text :description
      t.string :external_link
      t.integer :author_id

      t.timestamps null: false
    end
  end
end
