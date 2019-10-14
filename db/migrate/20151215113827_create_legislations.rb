class CreateLegislations < ActiveRecord::Migration
  def change
    create_table :legislations do |t|
      t.string :title
      t.text :body

      t.timestamps null: false
    end
  end
end
